package Pocker::Web::C::Image;
use strict;
use warnings;
use utf8;

use Pocker::Model::Image;
use Pocker::Model::Reloader;

sub index {
    my ($class, $c) = @_;
    return $c->render('image/index.tx', {
        images => Pocker::Model::Image->all,
    });
}

sub reload {
    my ($class, $c) = @_;
    Pocker::Model::Reloader->image;
    $c->redirect('/image');
}

sub delete {
    my ($class, $c, $args) = @_;

    my $id = $args->{id};
    my $image = Pocker::Model::Image->find(id => $id);

    $image->delete;
    return $c->redirect('/image');
}

sub pull {
    my ($class, $c) = @_;
    Pocker::Model::Image->pull( $c->req->parameters );
    $c->redirect('/image');
}

1;
