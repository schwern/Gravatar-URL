#!/usr/bin/perl -w

use Test::More;

BEGIN { use_ok 'Net::DNS';
        use_ok 'Libravatar::URL'; }

{
    my @domain_tests = (
        ['',
         undef,
        ],

        ['notanemail',
         undef,
        ],

        ['larry@example.com',
         'example.com',
        ],

        ['larry@example.com@example.org',
         'example.org',
        ],

        ['@example.org',
         'example.org',
        ],

        ['larry@@example.com',
         'example.com',
        ],
    );

    for my $test (@domain_tests) {
        my ($email, $domain) = @$test;
        is Libravatar::URL::email_domain($email), $domain;
    }

    my @url_tests = (
        [undef, undef,
         undef,
        ],

        ['example.com', undef,
         'http://example.com/avatar',
        ],

        ['example.com', 80,
         'http://example.com/avatar',
        ],

        ['example.com', 81,
         'http://example.com:81/avatar',
        ],
    );

    for my $test (@url_tests) {
        my ($target, $port, $url) = @$test;
        is Libravatar::URL::build_url($target, $port), $url;
    }

    my @srv_tests = (
        [[
         ],
         [undef, undef],
        ],

        [['_avatars._tcp.example.com. IN SRV 0 0 80 avatars.example.com',
         ],
         ['avatars.example.com', 80],
        ],

        [['_avatars._tcp.example.com. IN SRV 10 0 81 avatars2.example.com',
          '_avatars._tcp.example.com. IN SRV 0 0 80 avatars.example.com',
         ],
         ['avatars.example.com', 80],
        ],

        [['_avatars._tcp.example.com. IN SRV 10 0 83 avatars4.example.com',
          '_avatars._tcp.example.com. IN SRV 10 0 82 avatars3.example.com',
          '_avatars._tcp.example.com. IN SRV 1 0 81 avatars21.example.com',
          '_avatars._tcp.example.com. IN SRV 10 0 80 avatars.example.com',
         ],
         ['avatars21.example.com', 81],
        ],

        # The following ones are randomly selected which is why we
        # have to initialize the random number to a canned value

        # random_number = 49
        [['_avatars._tcp.example.com. IN SRV 10 1 83 avatars4.example.com',
          '_avatars._tcp.example.com. IN SRV 10 5 82 avatars3.example.com',
          '_avatars._tcp.example.com. IN SRV 10 10 8100 avatars2.example.com',
          '_avatars._tcp.example.com. IN SRV 10 50 800 avatars1.example.com',
          '_avatars._tcp.example.com. IN SRV 20 0 80 avatars.example.com',
         ],
         ['avatars1.example.com', 800],
        ],

        # random_number = 0
        [['_avatars._tcp.example.com. IN SRV 10 1 83 avatars4.example.com',
          '_avatars._tcp.example.com. IN SRV 10 0 82 avatars3.example.com',
          '_avatars._tcp.example.com. IN SRV 20 0 81 avatars2.example.com',
          '_avatars._tcp.example.com. IN SRV 20 0 80 avatars.example.com',
         ],
         ['avatars3.example.com', 82],
        ],

        # random_number = 1
        [['_avatars._tcp.example.com. IN SRV 10 0 83 avatars4.example.com',
          '_avatars._tcp.example.com. IN SRV 10 0 82 avatars3.example.com',
          '_avatars._tcp.example.com. IN SRV 10 10 601 avatars20.example.com',
          '_avatars._tcp.example.com. IN SRV 20 0 80 avatars.example.com',
         ],
         ['avatars20.example.com', 601],
        ],

        # random_number = 40
        [['_avatars._tcp.example.com. IN SRV 10 1 83 avatars4.example.com',
          '_avatars._tcp.example.com. IN SRV 10 5 82 avatars3.example.com',
          '_avatars._tcp.example.com. IN SRV 10 10 8100 avatars2.example.com',
          '_avatars._tcp.example.com. IN SRV 10 30 8 avatars10.example.com',
          '_avatars._tcp.example.com. IN SRV 10 50 800 avatars1.example.com',
          '_avatars._tcp.example.com. IN SRV 20 0 80 avatars.example.com',
         ],
         ['avatars10.example.com', 8],
        ],
    );

    srand(42); # to make these tests predictable

    for my $test (@srv_tests) {
        my ($srv_strings, $pair) = @$test;

        my @srv_records = ();
        for $str (@$srv_strings) {
            my $record = Net::DNS::RR->new($str);
            push @srv_records, $record;
        }

        my @result = Libravatar::URL::srv_hostname(@srv_records);
        is_deeply \@result, $pair;
    }

    $test_count = @domain_tests + @url_tests + @srv_tests + 2;
    done_testing($test_count);
}
