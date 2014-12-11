package Pocker::Web::Plugin::Profiler;
use strict;
use warnings;
use utf8;
use Module::Pluggable::Object;

sub init {
    my ($class, $c, $conf) = @_;
    my $namespace = scalar $c;
    return unless not $ENV{HARNESS_ACTIVE} and $ENV{PLACK_ENV} ne 'production';

    # Devel::KYTProf
    {
        require Devel::KYTProf;
        import Devel::KYTProf;

        my $conf = $conf->{kytprof};

        # settings
        Devel::KYTProf->logger($c->log_debug);
        Devel::KYTProf->namespace_regex(qr/$namespace/);
        Devel::KYTProf->threshold($conf->{threshold} // 1);
        Devel::KYTProf->remove_linefeed($conf->{remove_linefeed} // 1);

        # add controller methods
        my @modules = Module::Pluggable::Object->new(
            search_path => [
                "Pocker::Web::C",
                (ref $conf->{modules} eq 'ARRAY'? @{$conf->{modules}} : ()),
            ],
        )->plugins;
        Devel::KYTProf->add_profs($_, ':all') for @modules;

        # add render method
        Devel::KYTProf->add_prof($namespace, 'render');

        # mute
        if (ref $conf->{mutes} eq 'ARRAY') {
            Devel::KYTProf->mute($_) for @{$conf->{mutes}};
        }
    }

    #  DBIx::QueryLog
    {
        require DBIx::QueryLog;
        import DBIx::QueryLog;

        my $conf = $conf->{querylog};

        # settings
        DBIx::QueryLog->logger($c->log_debug);
        DBIx::QueryLog->threshold($conf->{threshold} // 0);
        DBIx::QueryLog->color('yellow');
        DBIx::QueryLog->compact(1);
        DBIx::QueryLog->explain($conf->{explain} // 1);
    }
}

1;
