package Archive::Lha::Header::Level2;

use strict;
use warnings;
use Carp;
use Archive::Lha::Header::Base;
use Archive::Lha::Header::Utils;

sub new {
  my ($class, $stream) = @_;

  my $start = $stream->tell;
  my $size  = _short( split '', $stream->read(2) );

  croak "Header is broken: size is null" unless $size;
  croak "Header is too large" if $size > 4096;

  $stream->seek( $start );
  my @bits = split '', $stream->read( $size );

  my %header;
  $header{header_top}    = $start;
  $header{header_size}   = $size;
  $header{method}        = join '', @bits[3..5];
  $header{encoded_size}  = _int( @bits[7..10] );
  $header{original_size} = _int( @bits[11..14] );
  $header{timestamp}     = _int( @bits[15..18] );
  $header{crc16}         = _short( @bits[21..22] );
  $header{os}            = _os_id( $bits[23] );
  $header{data_top}      = $start + $size;
  $header{next_header}   = $header{data_top} + $header{encoded_size};
  my $extended_size = _short( @bits[24..25] );
  my $from = 26;
  while( $extended_size ) {
    my $to = $from + $extended_size - 1;
    my ($next, %hash) = _extended_header( @bits[$from..$to] );
    %header = (%header, %hash) if %hash;
    $extended_size = $next;
    $from = $to + 1;
  }

  bless \%header, $class;
}

1;

__END__

=head1 NAME

Archive::Lha::Header::Level2

=head1 DESCRIPTION

You usually don't need to use this directly. See L<Archive::Lha::Header> for examples.

This parses Level 2 headers found in the recent archives. Level 2 header uses extended headers to store longer file/directory names. 

=head1 METHODS

=head2 new

parses a stream and creates an object.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
