package Pocker::CLI::DumpSchema;
use strict;
use warnings;
use utf8;
use DBI;
use Path::Tiny;
use Teng::Schema::Dumper;
use Test::mysqld;
use Pocker::Schema;

my $inflate = <<'END';
    inflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return Time::Piece::Plus->parse_mysql_datetime(str => $col_value);
    };
    deflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return ref $col_value eq 'Time::Piece::Plus'
            ? $col_value->mysql_datetime : die "Time::Piece::Plus obj only.";
    };
END

sub run {
    path('sql', 'pocker.sql')->spew_utf8( Pocker::Schema->output );
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '',
        },
    );
    my $dbh = DBI->connect($mysqld->dsn);

    my $table_definition = path('sql', 'pocker.sql')->slurp_utf8;
    for my $stmt ( split /;/, $table_definition ) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr;
    }

    my $schema = Teng::Schema::Dumper->dump(
        dbh            => $dbh,
        namespace      => 'Pocker::DB',
        base_row_class => 'Pocker::DB::Row',
        inflate        => {
            map { $_ => $inflate } map { $_ =~ /`(\w+)`\.`(\w+)`/; $2 } ( $dbh->tables )
        },
    );
    my $require_modules = join "\n", map { "use $_;" } qw/
        Time::Piece::Plus
    /;
    $schema =~ s/use Teng::Schema::Declare;/use Teng::Schema::Declare;\n$require_modules/;

    path('lib', 'Pocker', 'DB', 'Schema.pm')->spew_utf8($schema);
}

1;
