package Pocker::Model::Container;
use strict;
use warnings;
use utf8;

use Time::Piece::Plus;
use Try::Lite;
use JSON;
use Pocker::Model::Base;
use Pocker::Model::Image;
use Pocker::Model::ContainerObject;
use Pocker::Validator;

sub create {
    my ($class, $params) = @_;
    my ($ip, $hostname, $image_name, $command, $command_text, $env) = @$params{qw/ip hostname image command command_text env/};

    my $v = Pocker::Validator->validate($params,
        ip       => [ 'NOT_NULL', 'IP_ADDR' ],
        hostname => [ 'NOT_NULL', 'HOSTNAME', [ 'LENGTH', 1, 64 ] ],
        image    => [ 'NOT_NULL', [ 'LENGTH', 1, 64 ] ],
    );
    $v->set_error(hostname => 'DUPLICATION') if db->single(container => { hostname => $hostname });
    $v->set_error(ip => 'DUPLICATION') if db->single(container => { ip => $ip });
    $v->exception if $v->has_error;

    my ($repository, $tag) = split /:/, $image_name;
    my $image = Pocker::Model::Image->find( repository => $repository, tag => $tag );
    my $image_config = $image->inspect;

    my $container_env = [ split /\n/, $env ];

    my $container_command = $command eq 'init' ? '/sbin/init 3' : $command eq 'text' ? $command_text : $image_config->{Config}->{Cmd};
    $container_command = [ split /\s+/, $container_command ] if ref $container_command ne 'ARRAY';

    my $container = docker->container->create(
        image    => $image_name,
        hostname => $hostname,
        cmd      => $container_command,
        env      => $container_env,
    );

    my $c = db->insert(container => {
        id         => $container->{Id},
        ip         => $ip,
        hostname   => $hostname,
        image      => $image_name,
        status     => 0,
        created_at => scalar localtime,
        updated_at => scalar localtime,
    });

    return "${class}Object"->new( $c );
}

sub search {
    my ($class, %args) = @_;
    my $containers = db->search(container => { %args });
    return [ sort { $a->ip->octet(4) <=> $b->ip->octet(4) } map { "${class}Object"->new($_) } $containers->all ];
}
sub all { shift->search }

sub find {
    my ($class, %args) = @_;
    my $container = db->single(container => { %args });
    return $container ? "${class}Object"->new($container) : undef;
}

1;
