package Pocker::Test::DB;
use strict;
use warnings;
use utf8;
use DBI;
use Path::Tiny;

sub prepare {
    my ($class, $mysqld) = @_;
    $class->setup($mysqld);
}

sub setup {
    my ($class, $mysqld) = @_;

    my $dbh = DBI->connect($mysqld->dsn);
    my $table_definition = path('sql', 'pocker.sql')->slurp_utf8;
    for my $stmt ( split /;/, $table_definition ) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr;
    }
}

sub clear {
    my ($class, $dsn) = @_;

    my $dbh = DBI->connect($dsn);
    $dbh->do("DELETE FROM $_") or die $dbh->errstr for $dbh->tables;
}

1;
