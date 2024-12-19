package Archive::Lha::Debug;

use strict;
use warnings;
use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;
use Data::Dump;

my $logger = Log::Dispatch->new;
   $logger->add( Log::Dispatch::File->new(
     name      => 'file',
     min_level => 'debug',
     filename  => 'debug.log'
   ));
   $logger->add( Log::Dispatch::Screen->new(
     name      => 'screen',
     min_level => 'info',
   ));

sub import {
  my $class = shift;
  my $caller = caller;

  {
    no strict 'refs';
    *{"$caller\::DEBUG"} = sub {
      my ($level, @messages) = @_;
      my $message = join ' ', map {
        unless ( ref $_ ) { $_ }
        elsif  ( ref $_ eq 'Archive::Lha::Table' ) { $_->stringify }
        else   { Data::Dump::dump($_) }
      } @messages;
      $message .= "\n";
      $logger->log( level => $level, message => $message );
    };
  }
}

1;

__END__

=head1 NAME

Archive::Lha::Debug

=head1 SYNOPSIS

  DEBUG( warn => "You don't need to use this" );

=head1 DESCRIPTION

This is a simple wrapper of Log::Dispatch for debugging. See L<Log::Dispatch> for details.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
