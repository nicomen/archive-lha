use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Archive::Lha',
    VERSION_FROM  => 'lib/Archive/Lha.pm',
    ABSTRACT_FROM => 'lib/Archive/Lha.pm',
    AUTHOR        => [
        'Kenichi Ishigaki <ishigaki@cpan.org>',
        'Nicolas Mendoza <mendoza@pvv.ntnu.no>',
    ],
    LICENSE       => 'perl',
    XSMULTI       => 1,
    PREREQ_PM     => {
        'Exporter::Lite' => 0,
        'POSIX'          => 0,
    },
    TEST_REQUIRES => {
        'Test::More'  => 0,
        'Time::Moment' => 0,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/nicomen/Archive-Lha.git',
                web  => 'https://github.com/nicomen/Archive-Lha',
            },
            bugtracker => {
                web => 'https://github.com/nicomen/Archive-Lha/issues',
            },
        },
    },
    MIN_PERL_VERSION => '5.010',
    EXE_FILES        => ['bin/plha'],
    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean            => { FILES => 'Archive-Lha-*' },
);
