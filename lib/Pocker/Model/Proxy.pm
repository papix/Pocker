package Pocker::Model::Proxy;
use strict;
use warnings;
use utf8;

use Time::Piece::Plus;
use Pocker::Model::Base;
use Pocker::Model::ProxyObject;
use Pocker::Validator;

sub create {
    my ($class, %args) = @_;
    my ($virtual_host, $listen_port) = @args{qw/virtual_host listen_port/};

    my $v = Pocker::Validator->validate(\%args,
        virtual_host => [ 'NOT_NULL' ],
        listen_port  => [ 'NOT_NULL' ],
    );
    $v->set_error(proxy => 'DUPLICATION') if db->single(
        proxy => { virtual_host => $virtual_host, listen_port => $listen_port }
    );
    $v->exception if $v->has_error;

    my $proxy = db->insert(proxy => {
        virtual_host => $virtual_host,
        listen_port  => $listen_port,
        created_at   => scalar localtime,
        updated_at   => scalar localtime,
    });

    return "${class}Object"->new( $proxy );
}

sub search {
    my ($class, %args) = @_;
    my $proxies = db->search(proxy => { %args });
    return [ sort { $a->virtual_host cmp $b->virtual_host } map { "${class}Object"->new($_) } $proxies->all ];
}
sub all { shift->search }

sub find {
    my ($class, %args) = @_;
    my $proxy = db->single(proxy => { %args });
    return $proxy ? "${class}Object"->new($proxy) : undef;
}

1;

__DATA__
upstream redmine-test.dox.internal.gaiax.com {

  server 192.168.17.17:80 weight=1;

}
server {
  listen       80;
  server_name  redmine-test.dox.internal.gaiax.com;
  location / {
    proxy_http_version 1.1;
    proxy_set_header Upgrade            $http_upgrade;
    proxy_set_header Connection         "upgrade";
    proxy_set_header Host               $host;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-Host   $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
    proxy_pass http://redmine-test.dox.internal.gaiax.com;
  }
}

