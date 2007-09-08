#!/usr/bin/perl -w

use strict;

use Test::More tests => 3;

BEGIN { use_ok "Gravatar::URL" }

is gravatar_id( 'alfred@example.com'),
   '6ffc501bf3b215384ea3abd3b6026735';

is gravatar_id( 'whatever@wherever.whichever', ),
   'a60fc0828e808b9a6a9d50f1792240c8';