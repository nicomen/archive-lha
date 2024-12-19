package Archive::Lha::Header::Level1;

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
  croak "Header is broken: checksum $checksum/$checksum1"
    unless $checksum == $checksum1;

  my %header;
  $header{header_top}      = $start;
  $header{header_size}     = $size;
  $header{header_checksum} = $checksum;
  $header{method}          = join '', @bits[3..5];
  $header{skip_size}       = _int( @bits[7..10] );
  $header{original_size}   = _int( @bits[11..14] );
  $header{timestamp}       = _dostime2utime( _int( @bits[15..18] ) );

  my $filename_length = ord( $bits[21] );
  $header{filename}   = join '', @bits[22..(21 + $filename_length)];
  $header{crc16}      = _short( @bits[(22 + $filename_length)..(23 + $filename_length)] );
  $header{os}         = _os_id( $bits[(24 + $filename_length)] );

  my $extended_from = 25 + $filename_length;
  my $extended_to   = scalar @bits - 3;

  if ( $extended_from < $extended_to ) {
    my %extended_area = _extended_area(
      @bits[$extended_from .. $extended_to]
    );
    %header = ( %header, %extended_area );
  }

  my $extended_size_total = 0;
  my $extended_size = _short( @bits[-2..-1] );
  while( $extended_size ) {
    @bits = split '', $stream->read( $extended_size );
    $extended_size_total += $extended_size;
    my ($next, %hash) = _extended_header( @bits );
    %header = (%header, %hash) if %hash;
    $extended_size = $next;
  }
  $header{encoded_size} = $header{skip_size} - $extended_size_total;

  $header{data_top}     = $start + $size + $extended_size_total;
  $header{next_header}  = $header{data_top} + $header{encoded_size};

  bless \%header, $class;
}

1;

__END__

=head1 NAME

Archive::Lha::Header::Level1

=head1 DESCRIPTION

You usually don't need to use this directly. See L<Archive::Lha::Header> for examples.

This parses Level 1 headers found mainly in older archives created in the MS-DOS era. Also, some of the older ports, including LHa for UNIX, still prefer this header for compatibility reasons. Historically, Level 1 header, which is actually a combination of previous Level 0 header and following Level 2 header, was designed to foster the transition to Level 2 header. However, as Level 2 implementation delayed, Level 1 archives prevailed enough and could not be ignored.

Level 1 header also has rather severe limitation for the path length of the archived file. However, Level 1 header can use extended headers to store longer file/directory names. Multibyte strings in the header may be encoded in shift-jis, or in euc-jp, or in other encodings.

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
