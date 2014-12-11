package Pocker::DB::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;
use Time::Piece::Plus;
base_row_class 'Pocker::DB::Row';
table {
    name 'container';
    pk 'id';
    columns (
        {name => 'id', type => 12},
        {name => 'ip', type => 12},
        {name => 'hostname', type => 12},
        {name => 'image', type => 12},
        {name => 'status', type => 4},
        {name => 'created_at', type => 11},
        {name => 'updated_at', type => 11},
    );
    inflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return Time::Piece::Plus->parse_mysql_datetime(str => $col_value);
    };
    deflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return ref $col_value eq 'Time::Piece::Plus'
            ? $col_value->mysql_datetime : die "Time::Piece::Plus obj only.";
    };
};

table {
    name 'container_proxy';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'proxy_id', type => 4},
        {name => 'container_id', type => 12},
        {name => 'proxy_port', type => 4},
        {name => 'created_at', type => 11},
    );
    inflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return Time::Piece::Plus->parse_mysql_datetime(str => $col_value);
    };
    deflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return ref $col_value eq 'Time::Piece::Plus'
            ? $col_value->mysql_datetime : die "Time::Piece::Plus obj only.";
    };
};

table {
    name 'image';
    pk 'id';
    columns (
        {name => 'id', type => 12},
        {name => 'repository', type => 12},
        {name => 'tag', type => 12},
        {name => 'created_at', type => 11},
        {name => 'updated_at', type => 11},
    );
    inflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return Time::Piece::Plus->parse_mysql_datetime(str => $col_value);
    };
    deflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return ref $col_value eq 'Time::Piece::Plus'
            ? $col_value->mysql_datetime : die "Time::Piece::Plus obj only.";
    };
};

table {
    name 'proxy';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'virtual_host', type => 12},
        {name => 'listen_port', type => 4},
        {name => 'created_at', type => 11},
        {name => 'updated_at', type => 11},
    );
    inflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return Time::Piece::Plus->parse_mysql_datetime(str => $col_value);
    };
    deflate qr/.+_at$/ => sub {
        my $col_value = shift;
        return ref $col_value eq 'Time::Piece::Plus'
            ? $col_value->mysql_datetime : die "Time::Piece::Plus obj only.";
    };
};

1;
