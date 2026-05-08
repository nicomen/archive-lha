#!/usr/bin/perl
# Benchmark Archive::Lha header parsing against lhasa
# Usage: perl -Iblib/lib -Iblib/arch bench/benchmark_list.pl [archive.lha ...]

use strict;
use warnings;
use Benchmark qw( cmpthese timethese );
use File::Basename;
use Archive::Lha::Header;
use Archive::Lha::Stream::File;

my @archives = @ARGV ? @ARGV : glob('t/archive/*.lzh t/archive/*.lha');

my $lhasa = do { chomp(my $p = `which lhasa 2>/dev/null`); $p } || 'lhasa';

for my $archive (sort @archives) {
    next unless -f $archive;
    my $name = basename($archive);

    # count entries
    my $n = 0;
    {
        my $s = Archive::Lha::Stream::File->new(file => $archive);
        while (defined(my $l = $s->search_header)) {
            my $h = Archive::Lha::Header->new(level => $l, stream => $s);
            $s->seek($h->{next_header});
            $n++;
        }
    }

    printf "\n=== %s (%d entries) ===\n", $name, $n;

    my $results = timethese(50, {
        'Archive::Lha' => sub {
            my $s = Archive::Lha::Stream::File->new(file => $archive);
            while (defined(my $l = $s->search_header)) {
                my $h = Archive::Lha::Header->new(level => $l, stream => $s);
                $s->seek($h->{next_header});
            }
        },
        'lhasa' => sub {
            open my $fh, '-|', $lhasa, 'l', $archive or die $!;
            1 while <$fh>;
            close $fh;
        },
    });
    cmpthese($results);
}
