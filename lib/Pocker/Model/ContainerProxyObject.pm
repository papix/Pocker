package Pocker::Model::ContainerProxyObject;
use strict;
use warnings;
use utf8;

use Mouse;
use Pocker::Model::Container;
use Pocker::Model::Proxy;
use Pocker::Model::Base;

extends 'Pocker::Model::Base';
has 'id'           => ( is => 'ro', isa => 'Int' );
has 'proxy_id'     => ( is => 'ro', isa => 'Int' );
has 'container_id' => ( is => 'ro', isa => 'Str');
has 'proxy_port'   => ( is => 'ro', isa => 'Int' );
has 'created_at'   => ( is => 'ro', isa => 'Time::Piece::Plus' );

has 'container' => ( is => 'ro', isa => 'Pocker::Model::ContainerObject', lazy_build => 1 );
has 'proxy'     => ( is => 'ro', isa => 'Pocker::Model::ProxyObject',     lazy_build => 1 );

sub _build_container { Pocker::Model::Container->find( id => shift->container_id ) }
sub _build_proxy     { Pocker::Model::Proxy->find( id => shift->proxy_id ) }

__PACKAGE__->meta->make_immutable;

1;
