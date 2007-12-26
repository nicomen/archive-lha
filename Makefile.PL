use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Archive::Lha',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/Archive/Lha.pm',
  ABSTRACT_FROM => 'lib/Archive/Lha.pm',
  PREREQ_PM => {
    'Carp'                => 0,
    'Data::Dump'          => 0,
    'Exporter::Lite'      => 0,
    'Fcntl'               => 0,
    'File::Basename'      => 0,
    'File::Path'          => 0,
    'File::Slurp'         => 0,
    'File::Spec'          => 0,
    'List::Util'          => 0,
    'Log::Dispatch'       => 0,
    'Test::UseAllModules' => 0,
    'Test::More'          => 0.47,
    'Time::Piece'         => 0,
  },
  EXE_FILES => ['tools/plha'],
  ($ExtUtils::MakeMaker::VERSION >= 6.31
    ? ( LICENSE => 'perl' )
    : ()
  ),
);
