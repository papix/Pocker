package Pocker::Model::Reloader;
use strict;
use warnings;
use utf8;

use Try::Lite;
use Time::Piece::Plus;
use List::Compare;
use Pocker::Model::Base;
use Pocker::Model::Image;
use Pocker::Model::Container;

sub image {
    my ($docker_images, $pocker_images);
    $docker_images->{$_->{Id}} = $_ for @{docker->image->list};
    $pocker_images->{$_->id}   = $_ for @{Pocker::Model::Image->all};

    my $lc = List::Compare->new([ keys %{$docker_images} ], [ keys %{$pocker_images} ]);

    my @docker_only_image_ids = $lc->get_Lonly;
    my @pocker_only_image_ids = $lc->get_Ronly;

    for my $image_id (@docker_only_image_ids) {
        my $image = $docker_images->{$image_id};
        my ($repository, $tag) = split /:/, $image->{RepoTags}->[0];
        next if $repository eq '<none>';

        Pocker::Model::Image->create(
            id         => $image_id,
            repository => $repository,
            tag        => $tag,
        );
    }
    $pocker_images->{$_}->delete for @pocker_only_image_ids;
}

sub container {
    for my $container (@{Pocker::Model::Container->all}) {
        my $d_container;
        try { $d_container = docker->container->inspect($container->id) } (
            'Pocker::DockerAPI::Exception::NoSuchContainer' => sub { $container->delete },
        );
        my $status = $d_container->{State}->{Running} ? 1 : 0;
        $container->update(
            status     => $status,
            updated_at => scalar localtime,
        ) if $status != $container->status;
    }
}

1;
