package Pocker::DockerAPI::Container;
use strict;
use warnings;
use utf8;

use Mouse;
use Smart::Args;
use Try::Lite;
use JSON;

extends 'Pocker::DockerAPI';

sub list {
    args(
        my $self,
        my $all => { optional => 1, default => 0 },
    );
    try {
        decode_json( $self->_get('/containers/json', {
            all => $all,
        }) );
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::BadParameter->throw if $@->status_code == 400;
            $@->rethrow;
        }
    );
}

sub inspect {
    args_pos(
        my $self,
        my $id => { isa => 'Str' },
    );
    try {
        decode_json( $self->_get(sprintf('/containers/%s/json', $id)) );
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            Pocker::DockerAPI::Exception::ImpossibleToAttach->throw if $@->status_code == 406;
        },
    );
}

sub create {
    args(
        my $self,
        my $image => { isa => 'Str' },
        my $cmd   => { isa => 'Str|ArrayRef' },
        my $hostname => { isa => 'Str', optional => '' },
        my $env           => { optional => 1, default => undef },
        my $attach_stderr => { optional => 1, default => 1 },
        my $attach_stdout => { optional => 1, default => 1 },
        my $attach_stdin  => { optional => 1, default => 0 },
        my $open_stdin    => { optional => 1, default => 0 },
        my $tty           => { optional => 1, default => 1 },
        my $exposed_ports => { optional => 1, default => +{} },
    );
    try {
        decode_json( $self->_post('/containers/create', {}, {
            Image        => $image,
            Cmd          => ref $cmd eq 'ARRAY' ? $cmd : [ $cmd ],
            Hostname     => $hostname,
            AttachStderr => \$attach_stderr,
            AttachStdout => \$attach_stdout,
            AttachStdin  => \$attach_stdin,
            OpenStdin    => \$open_stdin,
            Tty          => \$tty,
            ExposedPorts => $exposed_ports,
            Env          => $env
        }) );
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            Pocker::DockerAPI::Exception::ImpossibleToAttach->throw if $@->status_code == 406;
            $@->rethrow;
        },
    );
}

sub start {
    args(
        my $self,
        my $id            => { isa => 'Str' },
        my $port_bindings => { isa => 'HashRef', optional => 1, default => +{} },
    );
    try {
        $self->_post(sprintf('/containers/%s/start', $id), {}, {
            PortBindings => $port_bindings,
        });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::ContainerAlreadyStarted->throw if $@->status_code == 304;
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            $@->rethrow;
        },
    );
    return 1;
}

sub restart {
    args(
        my $self,
        my $id => { isa => 'Str' },
        my $t  => { isa => 'Int', optional => 1, default => 0 },
    );
    try {
        $self->_post(sprintf('/containers/%s/restart', $id), { t => $t });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            $@->rethrow;
        },
    );
    return 1;
}

sub stop {
    args(
        my $self,
        my $id => { isa => 'Str' },
        my $t  => { isa => 'Int', optional => 1, default => 0 },
    );
    try {
        $self->_post(sprintf('/containers/%s/stop', $id), { t => $t });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::ContainerAlreadyStopped->throw if $@->status_code == 304;
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            $@->rethrow;
        },
    );
    return 1;
}

sub kill {
    args(
        my $self,
        my $id     => { isa => 'Str' },
        my $signal => { optional => 1 },
    );
    try {
        $self->_post(sprintf('/containers/%s/kill', $id), { signal => $signal });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            $@->rethrow;
        },
    );
    return 1;
}

sub remove {
    args(
        my $self,
        my $id    => { isa => 'Str' },
        my $v     => { optional => 1, default => 0 },
        my $force => { optional => 1, defualt => 0 },
    );
    try {
        $self->_delete(sprintf('/containers/%s', $id), { v => $v, force => $force });
    } (
        'Pocker::DockerAPI::Exception::BadStatusCode' => sub {
            Pocker::DockerAPI::Exception::BadParameter->throw if $@->status_code == 400;
            Pocker::DockerAPI::Exception::NoSuchContainer->throw if $@->status_code == 404;
            $@->rethrow;
        },
    );
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
