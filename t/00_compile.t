use strict;
use warnings;
use Test::More;
use t::Util;

use Pocker;
use Pocker::Web;
use Pocker::Web::View;
use Pocker::Web::ViewFunctions;

use Pocker::DB::Schema;
use Pocker::Web::Dispatcher;

pass "All modules can load.";

done_testing;
