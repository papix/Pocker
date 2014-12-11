package Pocker::DockerAPI::Image;
use strict;
use warnings;
use utf8;

use Mouse;
use Archive::Tar;
use JSON;
use Smart::Args;
use Try::Lite;
use URI;

extends 'Pocker::DockerAPI';

sub list {
    args(
        my $self,
        my $all => { optional => 1, default => 0 },
    );
    try {
        decode_json( $self->_get('/images/json', { all => $all }) );
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::BadParameter->throw if $@->status_code == 400;
            $@->rethrow;
        }
    );
}

sub remove {
    args(
        my $self,
        my $id      => { isa => 'Str' },
        my $force   => { optional => 1, default => 0 },
        my $noprune => { optional => 1, default => 0 },
    );
    try {
        $self->_delete(sprintf('/images/%s', $id), { force => $force, noprune => $noprune });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchImage->throw if $@->status_code == 404;
            Pocker::DockerAPI::Exception::Conflict->throw if $@->status_code == 409;
            $@->rethrow;
        },
    );
    return 1;
}

sub build {
    args(
        my $self,
        my $dockerfile => { isa => 'Str|HashRef' },
        my $t          => { isa => 'Str', optional => 1 },
        my $q          => { optional => 1, default => 0 },
        my $nocache    => { optional => 1, default => 0 },
        my $rm         => { optional => 1, default => 0 },
    );
    my $tar = Archive::Tar->new;
    if (ref $dockerfile eq 'HASH') {
        $tar->add_data($_, $dockerfile->{$_}) for keys %{$dockerfile};
    } else {
        $tar->add_data('Dockerfile', $dockerfile);
    }

    my $uri = URI->new($self->url.'/build');
    $uri->query_form(
        t => $t, q => $q, nocache => $nocache, rm => $rm,
    );

    try {
        $self->_furl->post($uri, [
            'Content-Type' => 'application/tar',
        ], $tar->write);
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            $@->rethrow;
        },
    );
}

sub create {
    args(
        my $self,
        my $from_image => { isa => 'Str' },
        my $repo       => { isa => 'Str', optional => 1 },
        my $tag        => { isa => 'Str', optional => 1 },
        my $registry   => { isa => 'Str', optional => 1 },
    );
    my $uri = URI->new($self->url.'/images/create');
    $uri->query_form(
        fromImage => $from_image,
        repo      => $repo,
        tag       => $tag,
        registry  => $registry,
    );
    try {
        $self->_furl->post($uri);
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub { $@->rethrow },
    );
    return 1;
}

sub inspect {
    args_pos(
        my $self,
        my $name => { isa => 'Str' },
    );
    try {
        decode_json( $self->_get(sprintf('/images/%s/json', $name)) );
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchImage->throw if $@->status_code == 404;
            $@->rethrow;
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
