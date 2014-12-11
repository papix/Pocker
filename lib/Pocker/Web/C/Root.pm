package Pocker::Web::C::Root;
use strict;
use warnings;
use utf8;

sub root {
    my ($class, $c) = @_;

    return $c->render('index.tx');
}

1;
