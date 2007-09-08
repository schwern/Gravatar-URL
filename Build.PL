#!/usr/bin/perl -w

use strict;
use Module::Build;

my $builder = Module::Build->new(
    module_name => 'Gravatar::URL',
    license     => 'perl',

    meta_merge  => {
        resources => {
            bugtracker =>
              'http://rt.cpan.org/Public/Dist/Display.html?Name=Gravatar-URL',
            repository =>
              'http://svn.schwern.org/svn/CPAN/Gravatar-URL',
        },
        keywords => [ 'Gravatar' ],
    },

    requires             => {
        'Test::More'        => 0.40,
        'URI::Escape'       => 0,
        'Digest::MD5'       => 0,
        'Carp'              => 0,
    },
);

$builder->create_build_script();
