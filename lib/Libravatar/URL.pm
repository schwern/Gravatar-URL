package Libravatar::URL;

use strict;
use warnings;

our $VERSION = '1.02';

use Net::DNS;
use Gravatar::URL qw(gravatar_url);

use parent 'Exporter';
our @EXPORT = qw(
    libravatar_url
);

my $Libravatar_Base = "http://cdn.libravatar.org/avatar";


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
L<http://cdn.libravatar.org/avatar/>.

You should use L<https://seccdn.libravatar.org/avatar/> if you want
to serve avatars over HTTPS.

=head4 short_keys

If true, use short key names when constructing the URL.  "s" instead
of "size", "d" instead of "default" and so on.

short_keys defaults to true.

=head1 SEE ALSO

L<Gravatar::URL>

=cut

my %defaults = (
    short_keys => 1,
);

sub federated_url {
    my ( $email ) = @_;

    my $domain = undef;
    if ( $email =~ m/@([^@]+)$/ ) {
        $domain = $1;
    }
    return undef unless $domain;

    my $resolver = Net::DNS::Resolver->new;
    my $packet = $resolver->query('_avatars._tcp.' . $domain, 'SRV');

    if ( $packet and $packet->answer ) {
        my @records = $packet->answer;

        # TODO: honour $rr->priority and $rr->weight
        foreach my $rr (@records) {
            if ( 80 == $rr->port ) {
                return 'http://' . $rr->target . '/avatar';
            }
            else {
                return 'http://' . $rr->target . ':' . $rr->port .'/avatar';
            }
        }
    }
    return undef;
}

sub libravatar_url {
    my %args = @_;

    my $federated_url = federated_url($args{email});
    if ( $federated_url ) {
        $defaults{base} = $federated_url;
    }
    else {
        $defaults{base} = $Libravatar_Base;
    }

    Gravatar::URL::_apply_defaults(\%args, \%defaults);
    return gravatar_url(%args);
}

1;
