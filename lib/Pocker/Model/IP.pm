package Pocker::Model::IP;
use strict;
use warnings;
use utf8;

use overload q{""} => sub { shift->ip };

use Mouse;
use Smart::Args;

has 'ip' => ( is => 'ro', isa => 'Str' );

sub octet {
    args_pos( my $self, my $octet );
    return (split /\./, $self->ip)[$octet-1];
}

__PACKAGE__->meta->make_immutable;

1;
