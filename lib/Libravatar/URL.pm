package Libravatar::URL;

use strict;
use warnings;

our $VERSION = '1.02';

use Gravatar::URL qw(gravatar_url);

use parent 'Exporter';
our @EXPORT = qw(
    libravatar_url
);

my $Libravatar_Http_Base  = "http://cdn.libravatar.org/avatar";
my $Libravatar_Https_Base = "https://seccdn.libravatar.org/avatar";

=head1 NAME

Libravatar::URL - Make URLs for Libravatars from an email address

=head1 SYNOPSIS

    use Libravatar::URL;

    my $url = libravatar_url( email => 'larry@example.org' );

=head1 DESCRIPTION

See L<http://www.libravatar.org> for more information.

=head1 Functions

=head3 B<libravatar_url>

    my $url = libravatar_url( email => $email, %options );

Constructs a URL to fetch the Libravatar for the given $email address.

C<%options> are optional.  C<libravatar_url> will accept all the
options of L<Gravatar::URL/gravatar_url> except for C<rating> and C<border>.

The available options are...

=head4 size

Specifies the desired width and height of the avatar (they are square).

Valid values are from 1 to 512 inclusive. Any size other than 80 may
cause the original image to be downsampled using bicubic resampling
before output.

    size    => 40,  # 40 x 40 image

=head4 default

The url to use if the user has no avatar.

    default => "http://www.example.org/nobody.jpg"

Relative URLs will be relative to the base (ie. libravatar.org), not your web site.

Libravatar defines special values that you may use as a default to
produce dynamic default images. These are "identicon", "monsterid",
"wavatar" and "retro".  "404" will cause the URL to return an HTTP 404 "Not Found"
error instead and "mm" will display the same "mystery man" image for everybody.
See L<http://www.libravatar.org/api> for more info.

If omitted, Libravatar will serve up their default image, the orange butterfly.

=head4 base

This is the URL of the location of the Libravatar server you wish to
grab avatars from.  Defaults to
L<http://cdn.libravatar.org/avatar/> for HTTP and
L<https://seccdn.libravatar.org/avatar/> for HTTPS.

=head4 short_keys

If true, use short key names when constructing the URL.  "s" instead
of "size", "d" instead of "default" and so on.

short_keys defaults to true.

=head4 https

If true, serve avatars over HTTPS instead of HTTP.

You should select this option if your site is served over HTTPS to
avoid browser warnings about the presence of insecure content.

https defaults to false.

=cut

my %defaults = (
    short_keys => 1,
);

# Extra the domain component of an email address
sub email_domain {
    my ( $email ) = @_;
    return undef unless $email;

    if ( $email =~ m/@([^@]+)$/ ) {
        return $1;
    }
    return undef;
}

# Return the right (target, port) pair from a list of SRV records
sub srv_hostname {
    my @records = @_;
    return ( undef, undef ) unless scalar(@records) > 0;

    if ( 1 == scalar(@records) ) {
        my $rr = shift @records;
        return ( $rr->target, $rr->port );
    }

    # Keep only the servers in the top priority
    my @priority_records;
    my $total_weight = 0;
    my $top_priority = $records[0]->priority; # highest priority = lowest number

    foreach my $rr (@records) {
        if ( $rr->priority > $top_priority ) {
            # ignore the record ($rr has lower priority)
            next;
        }
        elsif ( $rr->priority < $top_priority ) {
            # reset the array ($rr has higher priority)
            $top_priority = $rr->priority;
            $total_weight = 0;
            @priority_records = ();
        }

        $total_weight += $rr->weight;

        if ( $rr->weight > 0 ) {
            push @priority_records, [ $total_weight, $rr ];
        }
        else {
            # Zero-weigth elements must come first
            unshift @priority_records, [ 0, $rr ];
        }
    }

    if ( 1 == scalar(@priority_records) ) {
        my $record = shift @priority_records;
        my ( $weighted_index, $rr ) = @$record;
        return ( $rr->target, $rr->port );
    }

    # Select first record according to RFC2782 weight ordering algorithm (page 3)
    my $random_number = int(rand($total_weight + 1));

    foreach my $record (@priority_records) {
        my ( $weighted_index, $rr ) = @$record;

        if ( $weighted_index >= $random_number ) {
            return ( $rr->target, $rr->port );
        }
    }

    die 'There is something wrong with our SRV weight ordering algorithm';
}

# Convert (target, port) to a full avatar base URL
sub build_url {
    my ( $target, $port, $https ) = @_;
    return undef unless $target;

    my $url = $https ? 'https' : 'http' . '://' . $target;
    if ( $port && !$https && ($port != 80) or $port && $https && ($port != 443) ) {
        $url .= ':' . $port;
    }
    $url .= '/avatar';

    return $url;
}

sub federated_url {
    my ( $email, $https ) = @_;
    my $domain = email_domain($email);
    return undef unless $domain;

    require Net::DNS::Resolver;
    my $fast_resolver = Net::DNS::Resolver->new(retry => 1, tcp_timeout => 1, udp_timeout => 1, dnssec => 1);
    my $srv_prefix = $https ? '_avatars-sec' : '_avatars';
    my $packet = $fast_resolver->query($srv_prefix . '._tcp.' . $domain, 'SRV');

    if ( $packet and $packet->answer ) {
        my ( $target, $port ) = srv_hostname($packet->answer);
        return build_url($target, $port, $https);
    }
    return undef;
}

sub libravatar_url {
    my %args = @_;
    my $custom_base = defined $args{base};

    $defaults{base_http} = $Libravatar_Http_Base;
    $defaults{base_https} = $Libravatar_Https_Base;
    Gravatar::URL::_apply_defaults(\%args, \%defaults);

    if ( !$custom_base ) {
        my $federated_url = federated_url($args{email}, $args{https});
        if ( $federated_url ) {
            $args{base} = $federated_url;
        }
    }

    return gravatar_url(%args);
}

=head1 LICENSE

Copyright 2011, Francois Marier <fmarier@gmail.com>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/artistic.html>


=head1 SEE ALSO

L<http://www.libravatar.org> - The Libravatar web site

L<http://www.libravatar.org/api> - The Libravatar API documentation

=cut

1;
