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

subtest 'plha l (lhasa l format)' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha l $lha 2>&1`;
    like $output, qr/MemLeakZ/, 'plha l lists archive contents';
    unlike $output, qr/Can't load|Can't locate/, 'No module loading errors';
    like $output, qr/^\s*PERMSSN/m, 'Has lhasa-style header';
    like $output, qr/\[Amiga\]/, 'Has [Amiga] prefix on file entries';
    like $output, qr/Total\s+\d+ files/, 'Has file count footer';
    unlike $output, qr/METHOD/, 'l format does not have METHOD column';
};

subtest 'plha lv (lhasa v format)' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha lv $lha 2>&1`;
    like $output, qr/MemLeakZ/, 'plha lv lists archive contents';
    like $output, qr/^\s*PERMSSN.*METHOD.*CRC/m, 'Has lhasa v header with METHOD and CRC';
    like $output, qr/\[Amiga\]/, 'Has [Amiga] prefix on file entries';
    like $output, qr/-lh\d-/, 'Shows compression method';
    like $output, qr/[0-9a-f]{4}/, 'Shows CRC';
    like $output, qr/Total\s+\d+ files/, 'Has file count footer';
    # Total line should have spacing for METHOD+CRC columns between ratio and date
    like $output, qr/Total.+\d+\.\d+%\s{12}\w{3}/, 'Total line has padding for METHOD+CRC columns';
};

subtest 'plha vv (LhA vv format)' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha vv $lha 2>&1`;
    like $output, qr/MemLeakZ/, 'plha vv lists archive contents';
    like $output, qr/Atts.*Method.*CRC.*OS/m, 'Has LhA vv header';
    like $output, qr/-lh\d-/, 'Shows compression method';
    like $output, qr/[0-9a-f]{4}/, 'Shows CRC';
    # LhA vv has filename on separate line
    my @lines = split /\n/, $output;
    my @name_lines = grep { /^MemLeakZ/ } @lines;
    ok scalar @name_lines > 0, 'Filename on its own line';
};

subtest 'plha l format matches lhasa' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha l $lha 2>&1`;
    my @file_lines = grep { /^\[Amiga\]/ } split /\n/, $output;
    ok scalar @file_lines > 0, 'Has file entries';
    for my $line (@file_lines) {
        like $line, qr/^\[Amiga\]\s+\d+\s+[\d.]+%\s+\w{3}\s+\d+\s+\d{4}\s+\S/, "File line format: $line";
    }
};

done_testing;
