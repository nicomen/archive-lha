package Archive::Lha;

use strict;
use warnings;

our $VERSION = '0.04';

require XSLoader;
XSLoader::load('Archive::Lha', $VERSION);

1;

__END__

=head1 NAME

Archive::Lha - extract .LZH archives

=head1 SYNOPSIS

  my $stream = Archive::Lha::Stream->new(file => 'some.lzh');
  while (defined(my $level = $stream->search_header)) {
    my $header = Archive::Lha::Header->new(
      level  => $level,
      stream => $stream,
    );
    $stream->seek($header->data_top);
    my $decoder = Archive::Lha::Decode->new(
      header => $header,
      read   => sub { stream->read(@_) },
      write  => sub { print @_ },
    );
    my $crc = $decoder->decode;
    die "crc mismatch" if $crc != $header->crc16;
  }

=head1 DESCRIPTION

LHa family is one of the lagacy but prevailing (and historically important) archivers. Though it has lost former popularity, it is still used widely in Japan, and reportedly, in Amiga world. And we have lots of LHa archives created under various environments at hand.

This package offers rather crude methods to decode/extract files from LHa archives. As of writing this, I'm not inclined to support creating/updating archives for various reasons but this may change. As for decoding, I'll probably add if testable (and preferably uploadable) archives should be found or offered.

=head1 KNOWN LIMITATION

As you suspect, this is slow. Really slow. Some of the code is written in XS/C, but it may take minutes to extract larger archives (well, I must confess, the prototype of this module, written in pure perl, took hours to extract them). If you need more speed, just use native archivers such as LHa for UNIX, or unlha32.dll for MSWin32. They have their own limitations (such as single-threadedness, may need temporary files, and others), but they're much faster, and would take seconds to extract.

=head1 ACKNOWLEDGMENT

The decoding (XS) part is based on the C sources of LHa for UNIX version 1.14i-ac20050924p1. Though I modified a lot not only to XSify but also to make it (relatively) thread-safe and easy to understand, I'm not fair if I omit the names of the original authors/contributors. If you find this port valuable, kudos be to them. If you find something wrong, most probably that'd be my fault.

According to the original C sources, those parts of LHa for UNIX version 1.14i-ac20050924p1 are copyrighted by Nobutaka Watazaki (1993-1995), Tsugio Okamoto (1996-2000?), and Koji Arai (2002-). I'm grateful to them, and also to all the people who involved in the development of LHa family including Masaru Oki, Yoichi Tagawa, Haruhiko Okumura, Haruyasu Yoshizaki, Kazuhiko Miki and others.

Other parts including a header file and perl sources are mine or of contributor(s) to this perl port. See appropriate POD sections for details.

=head1 SEE ALSO

Most of these are written in Japanese.

=over 4

=item L<http://sourceforge.jp/projects/lha/> (LHa for UNIX project)

=item L<http://homepage1.nifty.com/dangan/en/Content/Program/Java/jLHA/Notes/Notes.html> for details of LHa headers (en).

=item L<http://lha.sourceforge.jp/history.html> for the history of LHa (for UNIX).

=item L<http://oku.edu.mie-u.ac.jp/~okumura/compression/oldstory.html> for the older history of LHa/LHarc

=back

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki, unless otherwise noted. See above.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
