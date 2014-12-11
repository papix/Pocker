package Pocker::Web::ViewFunctions;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);
use Module::Functions;
use File::Spec;

our @EXPORT = get_public_functions();

sub commify {
    local $_  = shift;
    1 while s/((?:\A|[^.0-9])[-+]?\d+)(\d{3})/$1,$2/s;
    return $_;
}

sub c { Pocker->context() }
sub uri_with { Pocker->context()->req->uri_with(@_) }
sub uri_for { Pocker->context()->uri_for(@_) }

{
    my %static_file_cache;
    sub static_file {
        my $fname = shift;
        my $c = Pocker->context;
        if (not exists $static_file_cache{$fname}) {
            my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
            $static_file_cache{$fname} = (stat $fullpath)[9];
        }
        return $c->uri_for(
            $fname, {
                't' => $static_file_cache{$fname} || 0
            }
        );
    }
}

use Pocker::Model::Container;
use List::Compare;

sub unused_ipaddresses {
    my $containers = Pocker::Model::Container->all;
    my $lc = List::Compare->new(
        [ 1..250 ],
        [ map { $_->ip->octet(4) } @{ $containers } ],
    );
    return [ sort { $a <=> $b } $lc->get_Lonly ];
}

1;
