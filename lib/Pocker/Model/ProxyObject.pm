package Pocker::Model::ProxyObject;
use strict;
use warnings;
use utf8;

use Mouse;
use Time::Piece::Plus;
use Pocker::Model::Base;
use Pocker::Model::Container;
use Pocker::Model::ContainerProxy;

extends 'Pocker::Model::Base';
has 'id'           => ( is => 'ro', isa => 'Int' );
has 'virtual_host' => ( is => 'ro', isa => 'Str' );
has 'listen_port'  => ( is => 'ro', isa => 'Int' );
has 'created_at'   => ( is => 'ro', isa => 'Time::Piece::Plus' );
has 'updated_at'   => ( is => 'ro', isa => 'Time::Piece::Plus' );

before 'delete' => sub {
    my ($self) = @_;
    $_->delete for @{ $self->mapping };
};

sub mapping {
    my ($self) = @_;
    return Pocker::Model::ContainerProxy->search( proxy_id => $self->id );
}

sub create_mapping {
    my ($self, %args) = @_;
    Pocker::Model::ContainerProxy->create(
        proxy_id     => $self->id,
        container_id => $args{container_id},
        proxy_port   => $args{proxy_port},
    ) unless Pocker::Model::ContainerProxy->find(
        proxy_id     => $self->id,
        container_id => $args{container_id},
        proxy_port   => $args{proxy_port},
    );
}

__PACKAGE__->meta->make_immutable;

1;
