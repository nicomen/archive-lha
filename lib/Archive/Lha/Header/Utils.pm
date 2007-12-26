package Archive::Lha::Header::Utils;

use strict;
use warnings;
use Carp;
use Time::Piece;
use Exporter::Lite;

our @EXPORT = qw(
  _int _short _dostime2utime _os_id _extended_header
);

sub _int   { unpack 'I', ( pack 'aaaa', @_ ) }
sub _short { unpack 'S', ( pack 'aa', @_ ) }

sub _dostime2utime {
  my ($year, $mon, $day, $hour, $min, $sec) =
    map { eval('0b'.$_) }
    unpack 'a7a4a5a5a6a5', unpack 'B32', pack 'N', @_;
  $year += 1980;
  $sec  *= 2;

  my $timestr = sprintf( '%04d-%02d-%02d %02d:%02d:%02d',
                         $year, $mon, $day, $hour, $min, $sec );

  Time::Piece->strptime($timestr => '%Y-%m-%d %H:%M:%S')->epoch;
}

sub _os_id {
  my $hex = ord( shift );

  return [ M => 'MS-DOS' ]    if $hex == 0x4D;
  return [ w => 'WinNT' ]     if $hex == 0x57;
  return [ w => 'Win95' ]     if $hex == 0x77;
  return [ g => 'generic' ]   if $hex == 0x00;
  return [ U => 'UNIX' ]      if $hex == 0x55;
  return [ m => 'Macintosh' ] if $hex == 0x6D;
  return [ J => 'Java VM' ]   if $hex == 0x4A;
  return [ 2 => 'OS/2' ]      if $hex == 0x32;
  return [ 9 => 'OS/9' ]      if $hex == 0x39;
  return [ K => 'OS/68K' ]    if $hex == 0x4B;
  return [ 3 => 'OS/386' ]    if $hex == 0x33;
  return [ H => 'Human68K' ]  if $hex == 0x48;
  return [ C => 'CP/M' ]      if $hex == 0x43;
  return [ F => 'FLEX' ]      if $hex == 0x46;
  return [ R => 'Runser' ]    if $hex == 0x52;
  return [ T => 'TownsOS' ]   if $hex == 0x54;
  return [ X => 'XOSK' ]      if $hex == 0x58;
  return [ u => 'unknown' ];
}

sub _extended_header {
  my @bits = @_;
  my $next = _short( @bits[-2..-1] );

  my %hash;
  my $type = ord( $bits[0] );
  if ( $type == 0x00 ) {
    $hash{additional_crc} = _short( @bits[1..2] );
    # unlha32.dll seems to add something to bit3
    # but largely it can be ignored.
  }
  elsif ( $type == 0x01 ) {
    my $to = scalar @bits - 3;
    $hash{filename} = join '', @bits[1..$to];
  }
  elsif ( $type == 0x02 ) {
    my $to = scalar @bits - 3;
    $hash{directory} = join '', @bits[1..$to];
  }
  elsif ( $type == 0x39 ) {
    # Multi-disc header can be ignored.
  }
  elsif ( $type == 0x3F ) {
    # Comment header can be ignored.
  }
  elsif ( $type == 0x40 ) {
    # DOS attribute header; ignored temporarily
  }
  elsif ( $type == 0x41 ) {
    # Windows timestamp header; ignored temporarily
  }
  elsif ( $type == 0x42 ) {
    # Filesize (over 4G) header; ignored temporarily
  }
  elsif ( $type == 0x46 ) {
    # Windows attribute? header; ignored temporarily
  }
  elsif ( $type == 0x50 ) {
    # Permission (for unix) header; ignored temporarily
  }
  elsif ( $type == 0x51 ) {
    # UID/GID (for unix) header; can be ignored?
  }
  elsif ( $type == 0x52 ) {
    # Group (for unix) header; can be ignored?
  }
  elsif ( $type == 0x54 ) {
    $hash{timestamp} = _int( @bits[1..4] );
  }
  elsif ( $type == 0x7D ) {
    # Capsule (for mac?) header; can be ignored?
  }
  elsif ( $type == 0x7E ) {
    # Extended attribute (for OS/2?) header; can be ignored?
  }
  else {
    warn "Unknown extended header type: ".sprintf('%0x', $type);
    warn "bits: ", join ', ', map { ord($_) } @bits;
  }

  return ($next, %hash);
}

1;

__END__

=head1 NAME

Archive::Lha::Header::Utils

=head1 DESCRIPTION

This is used internally to export several undocumented utility functions.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
