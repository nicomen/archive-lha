#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;

my $lha = "$Bin/data/_examples/MemLeakZ.lha";

subtest 'plha v' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha v $lha 2>&1`;
    like $output, qr/MemLeakZ/, 'plha v lists archive contents';
    unlike $output, qr/Can't load|Can't locate/, 'No module loading errors';
    like $output, qr/^Original\s+Packed\s+Ratio/m, 'Has plha v header';
    like $output, qr/\d+ files$/, 'Has file count footer';
};

subtest 'plha l' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha l $lha 2>&1`;
    like $output, qr/MemLeakZ/, 'plha l lists archive contents';
    unlike $output, qr/Can't load|Can't locate/, 'No module loading errors';
    like $output, qr/^\s*PERMSSN/m, 'Has lhasa-style header';
    like $output, qr/\[Amiga\]/, 'Has [Amiga] prefix on file entries';
    like $output, qr/Total\s+\d+ files/, 'Has file count footer';
};

subtest 'plha l format matches lhasa' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha l $lha 2>&1`;
    # Each file line should match: [Amiga]  <spaces>  SIZE  RATIO%  STAMP  NAME
    my @file_lines = grep { /^\[Amiga\]/ } split /\n/, $output;
    ok scalar @file_lines > 0, 'Has file entries';
    for my $line (@file_lines) {
        like $line, qr/^\[Amiga\]\s+\d+\s+[\d.]+%\s+\w{3}\s+\d+\s+\d{4}\s+\S/, "File line format: $line";
    }
};

done_testing;
