package Pocker::Model::Image;
use strict;
use warnings;
use utf8;

use Time::Piece::Plus;
use Pocker::Model::Base;
use Pocker::Model::Reloader;
use Pocker::Model::ImageObject;
use Pocker::Validator;

sub create {
    my ($class, %args) = @_;
    my ($id, $repository, $tag) = @args{qw/id repository tag/};

    my $v = Pocker::Validator->validate(\%args,
        id         => [ 'NOT_NULL' ],
        repository => [ 'NOT_NULL' ],
        tag        => [ 'NOT_NULL' ],
    );
    $v->exception if $v->has_error;

    my $image = db->insert(image => {
        id         => $id,
        repository => $repository,
        tag        => $tag,
        created_at => scalar localtime,
        updated_at => scalar localtime,
    });

    return "${class}Object"->new( $image );
}

sub pull {
    my ($class, $params) = @_;
    my ($repository) = @$params{qw/repository/};

    my $v = Pocker::Validator->validate($params,
        repository => [ 'NOT_NULL' ],
    );
    $v->exception if $v->has_error;

    qudo->enqueue('Pocker::Worker::Image', {
        arg => $repository, uniqkey => sprintf("%d-%s", time, $repository),
    });
}

sub search {
    my ($class, %args) = @_;
    my $images = db->search(image => { %args });
    return [ map { "${class}Object"->new($_) } $images->all ];
}
sub all { shift->search }

sub find {
    my ($class, %args) = @_;
    my $container = db->single(image => { %args });
    return $container ? "${class}Object"->new($container) : undef;
}

1;
