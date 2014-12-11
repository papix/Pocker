package Pocker::Model::ContainerProxy;
use strict;
use warnings;
use utf8;

use Time::Piece::Plus;
use Pocker::Model::Base;
use Pocker::Model::Container;
use Pocker::Model::ContainerProxyObject;
use Pocker::Model::Proxy;
use Pocker::Validator;

sub create {
    my ($class, %args) = @_;
    my ($proxy_id, $container_id, $proxy_port) = @args{qw/proxy_id container_id proxy_port/};

    my $v = Pocker::Validator->validate(\%args,
        proxy_id     => [ 'NOT_NULL' ],
        container_id => [ 'NOT_NULL' ],
        proxy_port   => [ 'NOT_NULL' ],
    );
    $v->set_error(proxy => 'NOT_FOUND') unless Pocker::Model::Proxy->find( id => $proxy_id );
    $v->set_error(container => 'NOT_FOUND') unless Pocker::Model::Container->find( id => $container_id );
    $v->exception if $v->has_error;

    my $container_proxy = db->insert(container_proxy => {
        proxy_id     => $proxy_id,
        container_id => $container_id,
        proxy_port   => $proxy_port,
        created_at   => scalar localtime,
    });
    return "${class}Object"->new($container_proxy);
}

sub search {
    my ($class, %args) = @_;
    my $container_proxies = db->search(container_proxy => { %args });
    return [ map { "${class}Object"->new($_) } $container_proxies->all ];
}
sub all { shift->search }

sub find {
    my ($class, %args) = @_;
    my $container_proxy = db->single(container_proxy => { %args });
    return $container_proxy ? "${class}Object"->new($container_proxy) : undef;
}

1;
