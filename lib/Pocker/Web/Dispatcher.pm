package Pocker::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Module::Find;

useall 'Pocker::Web::C';
base 'Pocker::Web::C';

get  '/' => 'Root#root';

get  '/container'              => 'Container#index';
get  '/container/reload'       => 'Container#reload';
get  '/container/create'       => 'Container#create_form';
post '/container/create'       => 'Container#create';
get  '/container/{ip}/detail'  => 'Container#detail';
post '/container/{ip}/start'   => 'Container#start';
post '/container/{ip}/restart' => 'Container#restart';
post '/container/{ip}/stop'    => 'Container#stop';
post '/container/{ip}/delete'  => 'Container#delete';

get  '/image'             => 'Image#index';
get  '/image/reload'      => 'Image#reload';
post '/image/{id}/delete' => 'Image#delete';
post '/image/pull'        => 'Image#pull';

get  '/proxy'               => 'Proxy#index';
get  '/proxy/create'        => 'Proxy#create_form';
post '/proxy/create'        => 'Proxy#create';
post '/proxy/{id}/delete'   => 'Proxy#delete';
post '/proxy/mapping/{proxy_id}/create'   => 'Proxy#create_mapping';
post '/proxy/mapping/{mapping_id}/delete' => 'Proxy#delete_mapping';

1;
