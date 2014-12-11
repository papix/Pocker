package Pocker::Web::Plugin::Session;
use strict;
use warnings;
use utf8;

use Amon2::Util;
use HTTP::Session2::ServerStore;
use CHI;

sub init {
    my ($class, $c) = @_;

    # Validate XSRF Token.
    $c->add_trigger(
        BEFORE_DISPATCH => sub {
            my ( $c ) = @_;
            if ($c->req->method ne 'GET' && $c->req->method ne 'HEAD') {
                my $token = $c->req->header('X-XSRF-TOKEN') || $c->req->param('XSRF-TOKEN');
                unless ($c->session->validate_xsrf_token($token)) {
                    return $c->create_simple_status_page(
                        403, 'XSRF detected.'
                    );
                }
            }
            return;
        },
    );

    Amon2::Util::add_method($c, 'session', \&_session);

    # Inject cookie header after dispatching.
    $c->add_trigger(
        AFTER_DISPATCH => sub {
            my ( $c, $res ) = @_;
            if ($c->{session} && $res->can('cookies')) {
                $c->{session}->finalize_plack_response($res);
            }
            return;
        },
    );
}

# $c->session() accessor.
sub _session {
    my $self = shift;

    if (!exists $self->{session}) {
        my $connect_info = $self->config->{redis};
        $self->{session} = HTTP::Session2::ServerStore->new(
            env       => $self->req->env,
            secret    => $self->config->{session_secret_token},
            get_store => sub {
                CHI->new(
                    driver    => 'Redis',
                    namespace => 'pocker',
                    server    => $connect_info,
                );
            },
        );
    }
    return $self->{session};
}

1;
__END__

=head1 DESCRIPTION

This module manages session for Pocker.

