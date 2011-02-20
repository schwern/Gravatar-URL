#!/usr/bin/perl -w

use Test::More 'no_plan';

BEGIN { use_ok 'Gravatar::URL'; }

{
    my $id = 'a60fc0828e808b9a6a9d50f1792240c8';
    my $email = 'whatever@wherever.whichever';
    my $base = 'http://www.gravatar.com/avatar';

    my @tests = (
        [{ email => $email },
         "$base/$id",
        ],
        
        [{ id => $id },
         "$base/$id",
        ],
        
        [{ email => $email,
           base  => 'http://example.com/gravatar'
         },
         "http://example.com/gravatar/$id",
        ],

        # Make sure we don't get a double slash after the base.
        [{ email => $email,
           base  => 'http://example.com/gravatar/'
         },
         "http://example.com/gravatar/$id",
        ],
        
        [{ default => "/local.png",
           email   => $email
         },
         "$base/$id?d=%2Flocal.png",
        ],
        
        [{ default => "/local.png",
           rating  => 'X',
           email   => $email,
         },
         "$base/$id?r=x&d=%2Flocal.png",
        ],
        
        [{ default  => "/local.png",
           email    => $email,
           rating   => 'R',
           size     => 80
         },
         "$base/$id?r=r&s=80&d=%2Flocal.png"
        ],

        [{ default => "/local.png",
           rating  => 'PG',
           size    => 45,
           email   => $email,
         },
         "$base/$id?r=pg&s=45&d=%2Flocal.png"
        ],

        [{ default => "/local.png",
           rating  => 'PG',
           size    => 45,
           email   => $email,
         },
         "$base/$id?r=pg&s=45&d=%2Flocal.png"
        ],

        [{ default => "/local.png",
           rating  => 'PG',
           size    => 45,
           email   => $email,
           short_keys => 1,
         },
         "$base/$id?r=pg&s=45&d=%2Flocal.png"
        ],
        [{ default => "/local.png",
           rating  => 'PG',
           size    => 45,
           email   => $email,
           short_keys => 0,
         },
         "$base/$id?rating=pg&size=45&default=%2Flocal.png"
        ],
    );

    # Add tests for the special defaults.
    for my $special ("identicon", "mm", "monsterid", "retro", "wavatar") {
        my $test = [{ default => $special,
                      email   => $email,
                    },
                    "$base/$id?d=$special",
                   ];
        push @tests, $test;
    }

    for my $test (@tests) {
        my($args, $url) = @$test;
        is gravatar_url( %$args ), $url, join ", ", keys %$args;
    }
}

