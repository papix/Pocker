package Pocker::Model::Base;
use strict;
use warnings;
use utf8;

use Mouse;
use Path::Tiny;
use Qudo;
use Time::Piece::Plus;
use Try::Tiny;
use Pocker::DB::Schema;
use Pocker::DB;
use Pocker::DockerAPI;

our $DB;
our $DOCKER;
our $QUDO;

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    if (ref $args[0] && defined $args[0]->{select_columns}) {
        my $obj = shift @args;
        push @args, map { $_ => $obj->$_ } @{ $obj->{select_columns} };
    }
    return $class->$orig( @args );
};

sub _table {
    my ($self) = @_;
    my @namespace = split /::/, ref $self;
    my $table = pop @namespace;
    $table =~ s/Object$//i;
    $table =~ s/(.)([A-Z])/$1_$2/g;
    return lc $table;
}

sub update {
    my ($self, @param) = @_;
    db()->update($self->_table, { @param }, { id => $self->id });
}

sub delete {
    my ($self, @param) = @_;
    db()->delete($self->_table, { id => $self->id });
}

__PACKAGE__->meta->make_immutable;

no Mouse;

sub import {
    my $caller = caller;
    return unless $caller =~ /Pocker::Model::/;

    no strict 'refs';
    *{"$caller\::db"}     = \&db;
    *{"$caller\::txn"}    = \&txn;
    *{"$caller\::docker"} = \&docker;
    *{"$caller\::qudo"}   = \&qudo;
}

sub db {
    if (! $DB) {
        my $config_path = path( 'config', lc( $ENV{PLACK_ENV} || 'development' ).'.pl' );
        my $config = do $config_path or die "$config_path: $!";
        my $conf = $config->{dbi} or die "Missing configuration about DBI";
        my $schema = Pocker::DB::Schema->instance;
        $DB = Pocker::DB->new(
            schema        => $schema,
            connect_info  => [ @$conf ],
            on_connect_do => [
                'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            ],
        );
    }
    $DB;
}

sub txn (&) {
    my $coderef = shift;
    my $txn = db()->txn_scope;
    try {
        my $retval = wantarray ? [ $coderef->() ] : $coderef->();
        $txn->commit;
        wantarray ? @{$retval} : $retval;
    } catch {
        my $e = shift;
        $txn->rollback;
        $e->rethrow;
    };
}

sub docker { $DOCKER ||= Pocker::DockerAPI->new }

sub qudo {
    if (! $QUDO) {
        my $config_path = path( 'config', lc( $ENV{PLACK_ENV} || 'development' ).'.pl' );
        my $config = do $config_path or die "$config_path: $!";
        my $conf = $config->{worker_dbi} or die "Missing configuration about DBI";

        $QUDO = Qudo->new(
            driver_class => 'Skinny',
            databases    => [{
                dsn      => $conf->[0],
                username => $conf->[1],
                password => $conf->[2],
            }],
        );
    }
    $QUDO;
}

1;
