package Pocker::Model::Nginx;
use strict;
use warnings;
use utf8;

use Path::Tiny;
use Smart::Args;
use Text::Xslate;
use Pocker::Model::Container;
use Pocker::Model::Proxy;

sub update {
    args( my $class );

    my $xslate     = Text::Xslate->new(path => [ './tmpl' ]);
    my $nginx_conf_content = $xslate->render('middleware/nginx.tx', {
        proxies    => Pocker::Model::Proxy->all,
        containers => Pocker::Model::Container->all,
    });
    my $nginx_conf = path('/etc/nginx/conf.pocker/pocker.conf');
    $nginx_conf->spew_utf8($nginx_conf_content);

    system("service nginx reload");
    return $nginx_conf_content;
}

1;
