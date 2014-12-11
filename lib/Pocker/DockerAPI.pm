package Pocker::DockerAPI;
use strict;
use warnings;
use utf8;

use Furl;
use JSON;
use Mouse;
use Smart::Args;
use URI;
use Pocker::DockerAPI::Image;
use Pocker::DockerAPI::Container;
use Pocker::DockerAPI::Exception;

has 'url'       => ( is => 'ro', isa => 'Str',  required => 1, default => 'http://0.0.0.0:4243' );
has 'image'     => ( is => 'ro', required => 1, lazy_build => 1 );
has 'container' => ( is => 'ro', required => 1, lazy_build => 1 );
has '_furl'     => ( is => 'ro', isa => 'Furl', required => 1, lazy_build => 1 );

sub _build_image {
    args( my $self );
    Pocker::DockerAPI::Image->new( url => $self->url, _furl => $self->_furl );
}

sub _build_container {
    args( my $self );
    Pocker::DockerAPI::Container->new( url => $self->url, _furl => $self->_furl );
}

sub _build__furl {
    Furl->new( timeout => 60 );
}

sub _get {
    args_pos(
        my $self,
        my $path  => { isa => 'Str' },
        my $query => { isa => 'HashRef', optional => 1 },
    );
    my $uri = URI->new($self->url . '/' . $path);
    $uri->query_form( %$query ) if $query;
    my $res = $self->_furl->get($uri);

    Pocker::DockerAPI::Exception::ServerError->throw( res => $res ) if $res->status == 500;
    Pocker::DockerAPI::Exception::BadStatusCode->throw( status_code => $res->status ) if $res->status !~ /^2/;

    return $res->content;
}

sub _post {
    args_pos(
        my $self,
        my $path    => { isa => 'Str' },
        my $query   => { isa => 'HashRef', optional => 1 },
        my $content => { isa => 'HashRef', optional => 1, default => +{} },
    );
    my $uri = URI->new($self->url . '/' . $path);
    $uri->query_form( %$query ) if $query;
    my $res = $self->_furl->post($uri, [
        'Content-Type' => 'application/json',
    ], encode_json($content));

    Pocker::DockerAPI::Exception::ServerError->throw( res => $res ) if $res->status == 500;
    Pocker::DockerAPI::Exception::BadStatusCode->throw( status_code => $res->status ) if $res->status !~ /^2/;

    return $res->content;
}

sub _delete {
    args_pos(
        my $self,
        my $path    => { isa => 'Str' },
        my $query   => { isa => 'HashRef', optional => 1 },
    );
    my $uri = URI->new($self->url . '/' . $path);
    $uri->query_form( %$query ) if $query;
    my $res = $self->_furl->delete($uri);

    Pocker::DockerAPI::Exception::ServerError->throw( res => $res ) if $res->status == 500;
    Pocker::DockerAPI::Exception::BadStatusCode->throw( status_code => $res->status ) if $res->status !~ /^2/;

    return $res->content;
}

sub info    { decode_json(shift->_get('/info'))    }
sub version { decode_json(shift->_get('/version')) }

__PACKAGE__->meta->make_immutable;

1;
