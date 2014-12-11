package Pocker::Model::ImageObject;
use strict;
use warnings;
use utf8;

use Mouse;
use Try::Tiny;
use Smart::Args;
use Time::Piece::Plus;
use Pocker::Model::Container;
use Pocker::Model::Base;

extends 'Pocker::Model::Base';
has 'id'         => ( is => 'ro', isa => 'Str' );
has 'repository' => ( is => 'ro', isa => 'Str' );
has 'tag'        => ( is => 'ro', isa => 'Str' );
has 'created_at' => ( is => 'ro', isa => 'Time::Piece::Plus' );
has 'updated_at' => ( is => 'ro', isa => 'Time::Piece::Plus' );
has 'container'  => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );

before 'delete' => sub {
    args( my $self );
    try { docker->image->remove(id => $self->id) };
};

sub _build_container {
    args( my $self );
    return Pocker::Model::Container->search(image => $self->repository.':'.$self->tag);
}

sub inspect {
    args( my $self );
    docker->image->inspect( join ':', $self->repository, $self->tag );
}

__PACKAGE__->meta->make_immutable;

1;
