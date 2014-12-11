package t::Util;

BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
    if ($ENV{PLACK_ENV} eq 'production') {
        die "Do not run a test script on deployment environment";
    }
}

use File::Basename;
use File::Spec;
use Test::More 0.98;

use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'lib'));
use parent qw/Exporter/;

our @EXPORT = qw(
    slurp apptest
);

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}

sub slurp {
    my $fname = shift;
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    scalar do { local $/; <$fh> };
}

use Pocker::Test::DB;
sub apptest {
    my ($note, $code) = @_;
    Test::More::subtest($note, $code);
    Pocker::Test::DB->clear($ENV{PERL_TEST_MYSQLPOOL_DSN});
}

use Test::RedisServer;
my $REDIS;

{
    unless (defined $ENV{PERL_TEST_REDIS}) {
        $REDIS = Test::RedisServer->new;
        $ENV{PERL_TEST_REDIS} = 'localhost:' . $REDIS->conf->{port}; 
    }
}

END { undef $REDIS }

1;
