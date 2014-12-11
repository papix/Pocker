package Pocker::Schema;
use strict;
use warnings;
use utf8;

use DBIx::Schema::DSL;

database 'MySQL';
create_database 'pocker';

add_table_options
    'mysql_table_type' => 'InnoDB',
    'mysql_charset'    => 'utf8';

create_table 'container' => columns {
    varchar  'id',         not_null, size => 64, primary_key;
    varchar  'ip',         not_null, size => 64;
    varchar  'hostname',   not_null, size => 64, unique;
    varchar  'image',      not_null, size => 64;
    tinyint  'status',     not_null, default => 0;
    datetime 'created_at', not_null;
    datetime 'updated_at', not_null;

    add_unique_index 'id_idx' => ['id'];
    add_unique_index 'ip_idx' => ['ip'];
};

create_table 'image' => columns {
    varchar 'id',          not_null, size => 64, primary_key;
    varchar 'repository',  not_null, size => 64;
    varchar 'tag',         not_null, size => 64;
    datetime 'created_at', not_null;
    datetime 'updated_at', not_null;

    add_unique_index 'id_idx' => ['id'];
};

create_table 'proxy' => columns {
    integer  'id',           not_null, unsigned, primary_key, auto_increment;
    varchar  'virtual_host', not_null, size => 64;
    integer  'listen_port',  not_null;
    datetime 'created_at',   not_null;
    datetime 'updated_at',   not_null;

    add_unique_index 'id_idx' => ['id'];
    add_index 'vh_port_idx'   => ['virtual_host', 'listen_port'];
};

create_table 'container_proxy' => columns {
    integer  'id',           not_null, unsigned, primary_key, auto_increment;
    integer  'proxy_id',     not_null, unsigned;
    varchar  'container_id', not_null, size => 64;
    integer  'proxy_port',   not_null, unsigned;
    datetime 'created_at',   not_null;

    add_unique_index 'id_idx' => ['id'];

    add_index 'proxy_id_idx'     => ['proxy_id'];
    add_index 'container_id_idx' => ['container_id'];
};

1;
