use strict;

use Test::More;
use Test::Tester;
use Test::Deep;

use lib 'lib';
use Test::Deep::This;

check_test(
    sub {
        cmp_deeply([5, 6], [abs (this - 4) < 2, 10 - sqrt(this) < this * 2]);
    },
    {
        ok => 1, # expect this to fail
    }
);

check_test(
    sub {
        cmp_deeply({ a => 4 }, { a => 10 - sqrt(this) < this * 2 });
    },
    {
        ok => 0, # expect this to fail
        diag => qq#Compared \$data->{"a"}\n   got : '4'\nexpect : ((10) - (sqrt (<<this>>))) < ((<<this>>) * (2))#, 
    }
);


done_testing();

