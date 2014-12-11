package Pocker::Web::C::Container;
use strict;
use warnings;
use utf8;

use Pocker::Model::Container;
use Pocker::Model::Image;
use Pocker::Model::Reloader;
use Pocker::Model::Nginx;
use Try::Lite;

sub index {
    my ($class, $c) = @_;
    return $c->render('container/index.tx', {
        containers => Pocker::Model::Container->all,
    });
}

sub reload {
    my ($class, $c) = @_;
    Pocker::Model::Reloader->container;
    $c->redirect('/container');
}

sub create_form {
    my ($class, $c) = @_;
    return $c->render('container/create.tx', {
        images => Pocker::Model::Image->all,
    });
}

sub create {
    my ($class, $c) = @_;

    try {
        my $container = Pocker::Model::Container->create( $c->req->parameters );
        $container->start;
        Pocker::Model::Nginx->update;
        $c->redirect('/container');
    } (
        'Pocker::Exception::Validator' => sub {
            $c->fillin_form($c->req);
            $c->render('container/create.tx', { validator => $@->v, images => Pocker::Model::Image->all });
        },
    );
}

sub detail {
    my ($class, $c, $args) = @_;
    my $ip = $args->{ip};
    my $container = Pocker::Model::Container->find(ip => $ip);
    return $c->render('container/detail.tx', {
        container => $container,
        info      => $container->inspect,
    });
}

sub start {
    my ($class, $c, $args) = @_;

    my $ip = $args->{ip};
    my $container = Pocker::Model::Container->find(ip => $ip);
    $container->start;
    return $c->redirect('/container');
}

sub restart {
    my ($class, $c, $args) = @_;

    my $ip = $args->{ip};
    my $container = Pocker::Model::Container->find(ip => $ip);
    $container->restart;
    return $c->redirect('/container');
}

sub stop {
    my ($class, $c, $args) = @_;

    my $ip = $args->{ip};
    my $container = Pocker::Model::Container->find(ip => $ip);

    $container->stop;
    return $c->redirect('/container');
}

sub delete {
    my ($class, $c, $args) = @_;

    my $ip = $args->{ip};
    my $container = Pocker::Model::Container->find(ip => $ip);

    $container->delete;
    Pocker::Model::Nginx->update;
    return $c->redirect('/container');
}

1;
