#!/usr/bin/perl -w

# Unfortunately, these tests require network access :(

use Test::More 'no_plan';

BEGIN { use_ok 'Libravatar::URL'; }

{
    my $id = 'a60fc0828e808b9a6a9d50f1792240c8';
    my $email = 'whatever@wherever.whichever';
    my $base = 'http://cdn.libravatar.org/avatar';

    my $id2 = 'e3c7bce0f581c8911b4979e2f54da1de';
    my $email2 = 'francois+1@catalyst.net.nz';
    my $base2 = 'http://static.avatars.catalyst.net.nz/avatar';

    my @tests = (
        [{ email => $email },
         "$base/$id",
        ],

        [{ email => $email2 },
         "$base2/$id2",
        ],
    );

    for my $test (@tests) {
        my($args, $url) = @$test;
        is libravatar_url( %$args ), $url, join ", ", keys %$args;
    }
}
