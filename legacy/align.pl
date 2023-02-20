use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Atlas;
use Aoddb;
use Data::Dumper;
use Dir::Self;
use threads;
use Thread::Queue;

my $barcode = $ARGV[0];
my $path;
my $bam;
if ($barcode =~ /\//) {
	$path = $barcode;
	$bam = "$barcode/result"
	} else {
	}

	opendir (my $dir, "$path") or die "$path";
	my @fasta;
	while (my $filename = readdir($dir)) {
		if (($filename =~ /.fastq/)or($filename =~ /.fq/)) {
			push @fasta, "$path/$filename";
			}
		}
	@fasta = sort @fasta;
	`bwa mem -t 10 \$hg19 $fasta[0] $fasta[1] > $bam.sam`;
	`samtools view -@ 10 -b $bam.sam > $bam.bam`;
	`samtools sort -@ 10 -m 1G $bam.bam -o $bam.sorted.bam`;
	`mv $bam.sorted.bam $bam.bam`;
	`samtools index $bam.bam`;
	`rm $bam.sam`;


