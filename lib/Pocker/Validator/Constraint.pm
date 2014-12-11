package Pocker::Validator::Constraint;
use strict;
use warnings;
use utf8;
use FormValidator::Lite::Constraint;

my $ipaddr = qr/^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/;
my $hostname = qr/^[a-zA-Z0-9\-\.]+$/;

rule 'IP_ADDR'  => sub { $_ =~ $ipaddr };
rule 'HOSTNAME' => sub { $_ =~ $hostname };

1;
