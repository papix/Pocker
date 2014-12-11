+{
    default => {
        dispatchers => [qw/screen/],
        screen => {
            class     => 'Log::Dispatch::Screen::Color',
            min_level => 'debug',
            newline   => 1,
            format    => '[%d{%Y-%m-%d %H:%M:%S}] [%p] %m at %F line %L',
            color     => {
                info    => { text => 'green' },
                debug   => { text => 'magenta' },
                warning => { text => 'yellow' },
                error   => { text => 'red' },
                alert   => { text => 'red', bold => 1 },
            },
        },
    },
    debug => {
        dispatchers => [qw/screen/],
        screen => {
            class     => 'Log::Dispatch::Screen::Color',
            min_level => 'debug',
            newline   => 1,
            format    => '[%d{%Y-%m-%d %H:%M:%S}] [%p] %m',
            color     => {
                debug   => { text => 'magenta' },
            },
        },
    }
};
