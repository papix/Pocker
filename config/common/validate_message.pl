use strict;
use warnings;
use utf8;
+{
    param => {},
    message => {
        'ip.not_null'    => 'IPアドレスを入力して下さい.',
        'ip.ip_addr'     => 'IPアドレスとして適切な形式ではありません.',
        'ip.duplication' => '既に使われているIPアドレスです.',

        'hostname.not_null' => 'ホスト名を入力して下さい.',
        'hostname.hostname' => 'ホスト名として適切な形式ではありません.',
        'hostname.duplication' => '既に使われているホスト名です.',

        'proxy.duplication'   => '同じ設定のプロキシが既に存在します.',
        'proxy_port.not_null' => 'Proxy Portが入力されていません.',
    },
    function => {},
};
