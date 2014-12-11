requires 'Amon2', '6.09';
requires 'CHI';
requires 'CHI::Driver::Redis';
requires 'DBD::mysql';
requires 'DBIx::QueryLog';
requires 'DBIx::Schema::DSL';
requires 'Daiku';
requires 'Devel::KYTProf';
requires 'GitDDL::Migrator';
requires 'HTML::FillInForm::Lite', '1.11';
requires 'HTTP::Session2', '1.03';
requires 'JSON', '2.50';
requires 'Log::Dispatch::Config';
requires 'Log::Dispatch::Configurator::Any';
requires 'Log::Dispatch::Screen::Color';
requires 'Module::Find';
requires 'Module::Functions', '2';
requires 'Module::Pluggable::Object';
requires 'Path::Tiny';
requires 'Plack::Middleware::ReverseProxy', '0.09';
requires 'Router::Boom', '0.06';
requires 'Starlet', '0.20';
requires 'Teng', '0.18';
requires 'Test::RedisServer';
requires 'Test::WWW::Mechanize::PSGI';
requires 'Text::ASCIITable';
requires 'Text::Xslate', '2.0009';
requires 'Time::Piece::Plus';
requires 'perl', '5.010_001';

requires 'Class::Accessor::Lite';
requires 'Exception::Tiny';
requires 'FormValidator::Lite';
requires 'Furl';
requires 'List::Compare';
requires 'Mouse';
requires 'Smart::Args';
requires 'Try::Lite';
requires 'Try::Tiny';
requires 'URI';
requires 'Qudo';
requires 'JSON::XS';

on configure => sub {
    requires 'Module::Build', '0.38';
    requires 'Module::CPANfile', '0.9010';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'App::Prove::Plugin::MySQLPool';
};
