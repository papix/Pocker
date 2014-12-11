package Pocker::Plugin::Logger;
use strict;
use warnings;
use utf8;
use Data::Dumper ();
use Log::Dispatch::Config;
use Log::Dispatch::Configurator::Any;
use Amon2::Util ();
use Text::ASCIITable;

use constant EXPLAIN => [qw/
    id select_type table type possible_keys key key_len ref rows extra
/];

sub init {
    my ($class, $c, $config) = @_;

    my $conf = $c->config->{logger} or die "missing configuration for 'logger'";

    Pocker::Plugin::Logger::Backend::Default->configure(Log::Dispatch::Configurator::Any->new($conf->{default}));
    Pocker::Plugin::Logger::Backend::Debug->configure(Log::Dispatch::Configurator::Any->new($conf->{debug}));

    my $logger = Pocker::Plugin::Logger::Backend::Default->instance;
    my $logger_debug = Pocker::Plugin::Logger::Backend::Debug->instance;

    $logger_debug->add_callback(sub {
        my %args = @_;

        return '' unless $args{message};
        if ($args{params}->{explain}) {
            my $t = Text::ASCIITable->new();
            $t->setCols(@{ EXPLAIN() });
            for my $explain ( @{ $args{params}->{explain} } ) {
                $t->addRow( map { $explain->{$_} // 'NULL' } @{ EXPLAIN() } );
            }
            $args{message} .= $t;
        }

        chomp $args{message};
        return $args{message};
    });
    $logger->add_callback(sub {
        my %args = @_;

        return '' unless $args{message};
        if (ref $args{message}) {
            local $Data::Dumper::Terse    = 1;
            local $Data::Dumper::Indent   = 1;
            local $Data::Dumper::Sortkeys = 1;
            $args{message} = Data::Dumper::Dumper($args{message});
        }

        chomp $args{message};
        return $args{message};
    });

    Amon2::Util::add_method($c, 'log', sub { $logger });
    Amon2::Util::add_method($c, 'log_debug', sub { $logger_debug });
}

package Pocker::Plugin::Logger::Backend::Default {
    use parent qw/Log::Dispatch::Config/;
}

package Pocker::Plugin::Logger::Backend::Debug {
    use parent qw/Log::Dispatch::Config/;
}

1;
