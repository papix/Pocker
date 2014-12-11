package Pocker::Web::C::Proxy;
use strict;
use warnings;
use utf8;

use Try::Lite;
use Pocker::Model::Proxy;
use Pocker::Model::ContainerProxy;
use Pocker::Model::Container;
use Pocker::Model::Nginx;

sub index {
    my ($class, $c) = @_;
    return $c->render('proxy/index.tx', {
        proxies    => Pocker::Model::Proxy->all,
        containers => Pocker::Model::Container->all,
    });
}

sub create_form {
    my ($class, $c) = @_;
    return $c->render('proxy/create.tx');
}

sub create {
    my ($class, $c) = @_;
    try {
        my $proxy = Pocker::Model::Proxy->create(
            virtual_host => $c->req->param('virtual_host'),
            listen_port  => $c->req->param('listen_port'),
        );
        $c->redirect('/proxy');
    } (
        'Pocker::Exception::Validator' => sub {
            $c->fillin_form($c->req);
            $c->render('proxy/create.tx', { validator => $@->v });
        },
    );
}

sub delete {
    my ($class, $c, $args) = @_;
    my $proxy = Pocker::Model::Proxy->find( id => $args->{id} );
    $proxy->delete;
    Pocker::Model::Nginx->update;
    $c->redirect('/proxy');
}

sub create_mapping {
    my ($class, $c, $args) = @_;

    my $proxy = Pocker::Model::Proxy->find(id => $args->{proxy_id});
    my $container_id = $c->req->param('container_id');
    my $proxy_port   = $c->req->param('proxy_port');

    try {
        $proxy->create_mapping(
            container_id => $container_id,
            proxy_port   => $proxy_port,
        );
        Pocker::Model::Nginx->update;
        $c->redirect('/proxy');
    } (
        'Pocker::Exception::Validator' => sub {
            $c->redirect('/proxy');
        },
    );
}

sub delete_mapping {
    my ($class, $c, $args) = @_;

    my $container_proxy = Pocker::Model::ContainerProxy->find( id => $args->{mapping_id} );
    $container_proxy->delete;
    Pocker::Model::Nginx->update;

    return $c->redirect('/proxy');
}

1;
