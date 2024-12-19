package Archive::Lha::Header::Base;

use strict;
use warnings;
use Carp;
use File::Spec;

sub import {
  my $class  = shift;
  my $caller = caller;

  my @accessors = qw(
    method header_top data_top next_header
    encoded_size original_size crc16 timestamp os
  );

  {
    no strict 'refs'; no warnings 'redefine';
    foreach my $name ( @accessors ) {
      *{"$class\::$name"} = sub { shift->{$name} };
    }
    push @{"$caller\::ISA"}, $class;
  }
}

sub pathname {
  my ($self, $from, $to) = @_;
  my $path;
  if ( $self->{pathname} ) {
    $path = _conv_sep( $self->{pathname} );
  }
  elsif ( $self->{directory} && $self->{filename} ) {
    $path = File::Spec->catfile(
      _conv_sep( $self->{directory} ),
      _conv_sep( $self->{filename} )
    );
  }
  elsif ( $self->{filename} ) {
    $path = _conv_sep( $self->{filename} );
  }

  # avoid traversal
  if ( File::Spec->file_name_is_absolute( $path ) ) {
    my ($vol, $dir, $file) = File::Spec->splitpath( $path );
    $path = File::Spec->catfile( '.', $dir, $file );
  }
  if ( $from && $to ) {
    require Encode;
    if ( lc $from eq 'guess' ) {
      require Encode::Guess;
      my $enc = Encode::Guess::guess_encoding(
        $path => qw( cp932 euc-jp )
      );
      if ( ref $enc ) {
        Encode::from_to( $path, $enc->name, $to );
      }
    }
    else {
      Encode::from_to( $path, $from, $to );
    }
  }
  return File::Spec->canonpath( $path );
}

sub dirname {
  my $self = shift;
  my $path = $self->pathname(@_);
  require File::Basename;
  return  File::Basename::dirname( $path );
}

sub _conv_sep {
  my $path = shift;

  $path =~ s{\xff}{/}g;
  return $path;
}

1;

__END__

=head1 NAME

Archive::Lha::Header::Base

=head1 DESCRIPTION

This provides several common accessors for convenient properties of LHa headers.

=head1 METHODS

=head2 method

returns by which method the file is archived.

=head2 header_top

returns from where the header part of the archived file begins.

=head2 data_top

returns from where the data part of the archived file begins.

=head2 next_header

returns from where the next header part begins.

=head2 encoded_size

returns the encoded/compressed size of the archived file.

=head2 original_size

returns the original size of the archived file.

=head2 crc16

returns CRC-16 value of the archived file.

=head2 timestamp

returns when the archived file was last updated.

=head2 os

returns under which OS the file was archived.

=head2 pathname

returns the canonical form of the pathname of the archived file. If you want native form, see the header's private properties which varies depending on the header level. Also note that the native form uses 0xff as a path separator.

You also can pass encoding options:

  # the pathname should have been encoded as 'euc-jp'
  $header->pathname('euc-jp' => 'shiftjis');

If you are not sure, you can let it guess:

  # original encoding of the path would be guessed
  $header->pathname('guess' => 'shiftjis');

=head2 dirname

returns directory part of the pathname. This is mainly used while creating parent directory for the file.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
