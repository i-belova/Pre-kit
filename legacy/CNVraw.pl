use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();

OUTER: foreach my $Analysis ($DB->control_analyses({"panel" => "OCAV3"})) {
	my $bam = $Analysis->Barcode->bam->path;
	my $total = `samtools view -c $bam`;
	chomp $total;
	my @dp;
	open (READ, "<targets.bed");
	while (<READ>) {
		chomp;
		my @mas = split/\t/;
		my $position = int(($mas[2] + $mas[1])/2);
		my $cmd = "samtools depth -aa -d 100000 -r '$mas[0]:$position-$position' $bam 2> /dev/null";
		my $dp1 = `$cmd`;
		chomp $dp1;
		undef $dp1 if length($dp1) < 2;
		unless (defined $dp1) {
			next OUTER;
			}
		push @dp, ((split/\t/, $dp1)[2]);
	}
	close READ;
	print "",$Analysis->Barcode->get_id,"\t$total\t",join("\t", @dp),"\n";
}











