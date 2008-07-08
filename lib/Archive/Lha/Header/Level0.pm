package Archive::Lha::Header::Level0;

use strict;
use warnings;
use Carp;
use List::Util qw( sum );
use Archive::Lha::Constants;
use Archive::Lha::Header::Base;
use Archive::Lha::Header::Utils;

sub new {
  my ($class, $stream) = @_;

  # stored size doesn't include the size of itself and the checksum
  my $start = $stream->tell;
  my $size = ord( $stream->read(1) ) + 2;

  croak "Header is broken: size is too small: $size" if $size < 27;

  $stream->seek( $start );
  my @bits = split '', $stream->read( $size );

  my $checksum  = ord( $bits[1] );
  my $checksum1 = ( sum( map { ord } @bits[2..$#bits] ) ) & CHAR_MAX;
  croak "Header is broken: pos:$start checksum $checksum/$checksum1"
    unless $checksum == $checksum1;

  my %header;
  $header{header_top}      = $start;
  $header{header_size}     = $size;
  $header{header_checksum} = $checksum;
  $header{method}          = join '', @bits[3..5];
  $header{encoded_size}    = _int( @bits[7..10] );
  $header{original_size}   = _int( @bits[11..14] );
  $header{timestamp}       = _dostime2utime( _int( @bits[15..18] ) );

  my $pathname_length = ord( $bits[21] );
  $header{pathname}   = join '', @bits[22..(21 + $pathname_length)];
  $header{crc16}      = _short( @bits[(22 + $pathname_length)..(23 + $pathname_length)] );

  my $extended_from = 24 + $pathname_length;
  my $extended_to   = $#bits;

  if ( $extended_from < $extended_to ) {
    my %extended_area = _extended_area(
      @bits[$extended_from .. $extended_to]
    );
    %header = ( %header, %extended_area );
  }

  $header{data_top}    = $start + $size;
  $header{next_header} = $header{data_top} + $header{encoded_size};

  bless \%header, $class;
}

1;

__END__

=head1 NAME

Archive::Lha::Header::Level0

=head1 DESCRIPTION

You usually don't need to use this directly. See L<Archive::Lha::Header> for examples.

This parses Level 0 headers found mainly in the oldest archives created in the MS-DOS era. Actually, it was designed for LHarc, one of the ancestors of LHa.

As Level 0 header has rather severe limitation for the path length of the archived file, recent archivers usually use Level 2 (or extended Level 1) headers. If you find multibyte strings in the header, most probably they are encoded in shift-jis.

=head1 METHODS

=head2 new

parses a stream and creates an object.

=head1 SEE ALSO

L<Archive::Lha::Header::Base>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
