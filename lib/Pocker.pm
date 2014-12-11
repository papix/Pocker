package Pocker;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
use 5.008001;

use Pocker::DB::Schema;
use Pocker::DB;

our $VERSION='0.01';

__PACKAGE__->load_plugins(
    '+Pocker::Plugin::Logger',
);

my $schema = Pocker::DB::Schema->instance;
sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{dbi}
            or die "Missing configuration about DBI";
        $c->{db} = Pocker::DB->new(
            schema        => $schema,
            connect_info  => [@$conf],
            on_connect_do => [
                'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            ],
        );
    }
    $c->{db};
}

use Pocker::Model::Reloader;
if ($ENV{PLACK_ENV} eq 'production') {
    Pocker::Model::Reloader->container;
    Pocker::Model::Reloader->image;
    Pocker::Model::Reloader->dockerfile;
}

1;
__END__

=head1 NAME

Pocker - Pocker

=head1 DESCRIPTION

This is a main context class for Pocker

=head1 AUTHOR

Pocker authors.

