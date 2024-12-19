package Archive::Lha::Decode::Base;

use strict;
use warnings;
use Carp;
use Archive::Lha::Constants;
use Archive::Lha;  # to load XS

sub import {
  my ($class, %options) = @_;
  my $caller = caller;

  {
    no strict 'refs'; no warnings 'redefine';

    my $dicbit = $options{dicbit} || 13;

    # should these really be configurable?
    # XXX: only if we want to support older/rare archives
    my $max_match = $options{max_match} || ( 1 << UCHAR_BIT );
    my $threshold = $options{threshold} || 3;
    my $np        = $options{np}        || $dicbit + 1;
    my $pbit      = _bit_length( $np );

    my $pt_table_bit  = $options{pt_table_bit} || 8;
    my $c_table_bit   = $options{c_table_bit}  || 12;
    my $pt_table_size = 1 << $pt_table_bit;
    my $c_table_size  = 1 << $c_table_bit;

    # XXX: not so sure if these are right for all
    my $npt = $pt_table_size >> 1;
    my $nt  = USHORT_BIT + 3;
    my $nc  = UCHAR_MAX  + $max_match + 2 - $threshold;

    my $tbit = _bit_length( $nt );
    my $cbit = _bit_length( $nc );

    *{"$caller\::NPT"}           = sub () { $npt };
    *{"$caller\::NP"}            = sub () { $np };
    *{"$caller\::NT"}            = sub () { $nt };
    *{"$caller\::NC"}            = sub () { $nc };
    *{"$caller\::PBIT"}          = sub () { $pbit };
    *{"$caller\::TBIT"}          = sub () { $tbit };
    *{"$caller\::CBIT"}          = sub () { $cbit };
    *{"$caller\::PT_TABLE_BIT"}  = sub () { $pt_table_bit };
    *{"$caller\::PT_TABLE_SIZE"} = sub () { $pt_table_size };
    *{"$caller\::C_TABLE_BIT"}   = sub () { $c_table_bit };
    *{"$caller\::C_TABLE_SIZE"}  = sub () { $c_table_size };
    *{"$caller\::DICSIZE"}       = sub () { 1 << $dicbit };
    *{"$caller\::MAXMATCH"}      = sub () { $max_match };
    *{"$caller\::THRESHOLD"}     = sub () { $threshold };

    my @accessors = qw( pt c tree bit );
    foreach my $name ( @accessors ) {
      *{"$class\::$name"} = sub { shift->{$name} };
    }
    push @{"$caller\::ISA"}, $class;
  }
}

sub new {
  my ($class, %options) = @_;

  my $header = $options{header};

  my $self  = bless {
    blocksize     => 0,
    read          => $options{read},
    write         => $options{write},
    encoded_size  => $header->{encoded_size},
    original_size => $header->{original_size},
    crc16         => $header->{crc16} || 0,
    DICSIZE       => $class->DICSIZE,
    MAXMATCH      => $class->MAXMATCH,
    THRESHOLD     => $class->THRESHOLD,
    NPT           => $class->NPT,
    NP            => $class->NP,
    NT            => $class->NT,
    NC            => $class->NC,
    PBIT          => $class->PBIT,
    TBIT          => $class->TBIT,
    CBIT          => $class->CBIT,
    PT_TABLE_BIT  => $class->PT_TABLE_BIT,
    PT_TABLE_SIZE => $class->PT_TABLE_SIZE,
    C_TABLE_BIT   => $class->C_TABLE_BIT,
    C_TABLE_SIZE  => $class->C_TABLE_SIZE,
  }, $class;

  $self;
}

1;

__END__

=head1 NAME

Archive::Lha::Decode::Base

=head1 DESCRIPTION

This is a base class for lh5-7 decoder. See L<Archive::Lha::Decode> for options and examples.

=head1 METHODS

=head2 new

creates an object.

=head2 decode

decodes the archived file and returns CRC-16. See XS source for details.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
