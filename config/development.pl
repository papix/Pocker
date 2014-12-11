use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $logger  = do File::Spec->catfile($basedir, 'config', 'common', 'logger.pl') or die;

+{
    dbi => [
        'dbi:mysql:database=pocker;host=localhost', 'root', ''
    ],
    worker_dbi => [
        'dbi:mysql:database=pocker_worker;host=localhost', 'root', ''
    ],
    redis => 'localhost:6379',
    logger => $logger,
    session_secret_token => 'SESSION_SECRET_TOKEN',
};
