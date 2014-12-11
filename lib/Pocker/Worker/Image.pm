package Pocker::Worker::Image;
use strict;
use warnings;
use utf8;

use parent 'Qudo::Worker';
use Try::Tiny;
use Pocker::DockerAPI;
use Pocker::Model::Reloader;

sub work {
    my ($class, $job) = @_;

    printf STDERR "[Start] image pull -> %s\n", $job->arg;
    try {
        my $docker = Pocker::DockerAPI->new;
        $docker->image->create( from_image => $job->arg );
        Pocker::Model::Reloader->image;
        printf STDERR "[Completed] image pull -> %s\n", $job->arg;
    } catch {
        printf STDERR "[Failed] image pull -> %s\n", $job->arg;
    };

    $job->completed;
}

1;
