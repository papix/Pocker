die unless defined $ENV{PERL_TEST_MYSQLPOOL_DSN};
die unless defined $ENV{PERL_TEST_REDIS};

use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $logger  = do File::Spec->catfile($basedir, 'config', 'common', 'logger.pl') or die;

+{
    dbi => [
        $ENV{PERL_TEST_MYSQLPOOL_DSN}, '', ''
    ],
    worker_dbi => [
        'dbi:mysql:database=pocker_worker;host=localhost', 'root', ''
    ],
    redis => $ENV{PERL_TEST_REDIS},
    logger => $logger,
    session_secret_token => 'SESSION_SECRET_TOKEN',
};
