package Pocker::CLI::DDL;
use strict;
use warnings;
use utf8;
use GitDDL;
use Path::Tiny;
use Try::Tiny;

my $env = $ENV{DAIKU_ENV} || 'development';
my $config_path = path('config', "${env}.pl")->absolute;
my $config = do $config_path;

my $gd = GitDDL->new(
    work_tree => './',
    ddl_file  => './sql/pocker.sql',
    dsn       => $config->{dbi},
);

sub check_version {
    if ( $gd->check_version ) {
        print "database is latest\n";
        return 1;
    } else {
        print "database is not latest\n";
        return 0;
    }
}

sub upgrade {
    try {
        $gd->upgrade_database;
    } catch {
        my $e = shift;
        print $e;
    };
}

sub diff {
    print $gd->diff
}

sub deploy {
    try {
        $gd->deploy;
    } catch {
        my $e = shift;
        print $e;
    };
}


1;

