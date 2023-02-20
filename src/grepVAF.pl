use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();
my @codes = @ARGV;

for (my $i = 0; $i < @codes; $i++) {
	print "\t$codes[$i]";
	}
print "\n";

open (READ, "<list");

while (<READ>) {
	chomp;
	my @mas = split/\t/;
	my $mut = $mas[0];
	print "$mut";
	#my $freq_ref = `perl ../ATLAS_software/aod-pipe/Pipe/popa/Scripts/HF_grep_var_count.pl $files[0] \$hg19 '$mut'`;
	#chomp $freq_ref;
	my $chr;
	my $position;
	if ($mut =~ /(\S+):(\d+)(\S+)>(\S+)/) {$chr = lc($1);$position = $2;}
	for (my $i = 0; $i < scalar @codes; $i++) {
		my $bam = $codes[$i];
		$bam = $DB->Barcode($bam)->bam->path;
		chomp $freq;
		$freq = 0 if $freq eq '';
		my $coverage = `samtools depth -d 100000 $bam -r '$chr:$position-$position'`;
		chomp $coverage;
		$coverage = [split /\t/, $coverage];
		$coverage = $coverage->[2];
		$coverage = 0 unless defined $coverage;
		chomp $freq;
		$freq = int($freq*10000)*100/10000;
		print "\t$coverage:",$freq;
		}
	print "\n";
	}

close READ;


