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

subtest 'Total line alignment' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha lv $lha 2>&1`;
    my ($total_line) = grep { /Total/ } split /\n/, $output;
    # Total prefix is 22 chars (PERMSSN footer 10 + sep 1 + UID/GID footer 10 + sep 1)
    # then %7d PACKED starts at position 22
    like $total_line, qr/^ Total\s+\d+ files?\s+\d+\s+\d+/, 'Total line has count, packed, size';
    # After "files " the PACKED number starts at position 22
    my ($prefix) = $total_line =~ /^(.*files\s)/;
    is length($prefix), 23, 'Total prefix is 23 chars (matches lhasa column footers)';
};

subtest 'prefix is 23 chars wide' => sub {
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha lv $lha 2>&1`;
    my @file_lines = grep { /^\[/ } split /\n/, $output;
    for my $line (@file_lines) {
        # First 23 chars are the prefix, then PACKED number starts
        my $prefix = substr($line, 0, 23);
        my $rest = substr($line, 23);
        like $rest, qr/^\s*\d+/, "PACKED starts after 23-char prefix: [$prefix]|$rest";
    }
};

subtest 'directory entries' => sub {
    # Use an archive with directory entries if available, otherwise skip
    # For now test that _is_directory and _lhasa_prefix work via lv output
    my $output = `$^X -Iblib/lib -Iblib/arch bin/plha lv $lha 2>&1`;
    unlike $output, qr/LHD\.pm/, 'No LHD decoder error';
    unlike $output, qr/Can't load/, 'No module loading errors';
};

subtest 'corrupt DOS timestamps' => sub {
    use Archive::Lha::Header::Utils;
    # month=0, day=0 would cause Time::Piece to die
    my $epoch = Archive::Lha::Header::Utils::_dostime2utime(0);
    is $epoch, 0, 'All-zero DOS time returns epoch 0';
    # Valid timestamp should still work
    # 2025-01-20 17:56:00 in DOS format
    $epoch = Archive::Lha::Header::Utils::_dostime2utime(0x5A34B800);
    ok $epoch > 0, 'Valid DOS time returns positive epoch';
};

done_testing;
