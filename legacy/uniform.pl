use strict;
use warnings;

`samtools depth -a -b /home/onco-admin/ATLAS_software/aod-pipe/panel_info/AODABCV1/AODABCV1.designed.bed $ARGV[0] > 2`;
open (READ, "<2");

my $sum = 0;
my $posCount = 0;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	++$posCount;
	$sum += $mas[2];
	}

close READ;


my $averageC = $sum/$posCount;
print "$averageC\n";
open (READ, "<2");

my $lowCount = 0;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	++$lowCount if $mas[2] < $averageC*0.2;
	}

close READ;
print "$lowCount\n";
print $lowCount/$posCount,"\n";

