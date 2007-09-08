#!/usr/bin/perl -w

use strict;

use Test::More 'no_plan';

BEGIN { use_ok 'Gravatar::URL' }

my @tests = (
    [ {},
      "Cannot generate a Gravatar URI without an email address or gravatar id"
    ],

    [ { email => 'foo@bar.com', id => '12345' },
      "Both an id and an email were given.  gravatar_url() only takes one"
    ],

    [ { email => 'foo@bar.com', rating => 'Q' },
      "Gravatar rating can only be G, PG, R, or X"
    ],

    [ { email => 'foo@bar.com', size => 0 },
      "Gravatar size must be 1 .. 80"
    ],

    [ { email => 'foo@bar.com', size => 90 },
      "Gravatar size must be 1 .. 80"
    ],
    
    [ { email => 'foo@bar.com', border => '00G' },
      "Border must be a 3 or 6 digit hex number in caps",
    ],

    [ { email => 'foo@bar.com', border => '0' },
      "Border must be a 3 or 6 digit hex number in caps",
    ],
);

for my $test (@tests) {
    my($args, $error) = @$test;
    
    eval { gravatar_url( %$args ) };
    is $@, sprintf "%s at %s line %d\n", $error, $0, __LINE__ - 1;
}
