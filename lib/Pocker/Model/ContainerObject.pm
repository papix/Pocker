package Pocker::Model::ContainerObject;
use strict;
use warnings;
use utf8;

use Mouse;
use Smart::Args;
use Time::Piece::Plus;
use Pocker::Model::Base;
use Pocker::Model::ContainerProxy;

extends 'Pocker::Model::Base';
has 'id'         => ( is => 'ro', isa => 'Str' );
has 'ip'         => ( is => 'ro', isa => 'Pocker::Model::IP' );
has 'hostname'   => ( is => 'ro', isa => 'Str' );
has 'image'      => ( is => 'ro', isa => 'Str' );
has 'status'     => ( is => 'ro', isa => 'Int' );
has 'created_at' => ( is => 'ro', isa => 'Time::Piece::Plus' );
has 'updated_at' => ( is => 'ro', isa => 'Time::Piece::Plus' );

before 'delete' => sub {
    args( my $self );

    my $container_proxies = Pocker::Model::ContainerProxy->search( container_id => $self->id );
    if (@{$container_proxies}) {
        $_->delete for @{$container_proxies};
    }
    docker->container->remove(id => $self->id);
};

sub start {
    args( my $self );
    $self->update(
        status     => 1,
        updated_at => scalar localtime,
    );
    docker->container->start(id => $self->id);
    $self->_pipework;
}

sub restart {
    args( my $self );
    $self->update(
        status     => 0,
        updated_at => scalar localtime,
    );
    docker->container->restart(id => $self->id);
    $self->_pipework;
    $self->update(
        status     => 1,
        updated_at => scalar localtime,
    );
}

sub stop {
    args( my $self );
    $self->update(
        status     => 0,
        updated_at => scalar localtime,
    );
    docker->container->stop(id => $self->id);
}

sub inspect {
    args( my $self );
    docker->container->inspect($self->id);
}

sub _pipework {
    args( my $self );
    my $id = $self->id;
    my $ip = $self->ip;
    system("pipework br1 $id $ip/24");
    system("ip addr add 192.168.10.254/24 dev br1");
}

__PACKAGE__->meta->make_immutable;

1;
