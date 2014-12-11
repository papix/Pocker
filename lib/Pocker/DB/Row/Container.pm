package Pocker::DB::Row::Container;
use strict;
use warnings;
use utf8;
use parent qw(Pocker::DB::Row);

use Pocker::Model::IP;

sub ip { Pocker::Model::IP->new(ip => shift->get_column('ip')) }

1;
