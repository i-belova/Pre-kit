use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();
foreach my $Analysis ($DB->analyses) {
	my $analysis_name = $Analysis->get_id;
	my $count = $DB->execute_select_single("SELECT COUNT(*) FROM MutationResult where analysisName = '$analysis_name'");
	next if $count ne 0;
	my $vcf = $Analysis->vcf;
	unless (defined($vcf)) {
		$vcf = $Analysis->vcf_raw;
		}
	next unless defined $vcf;
	$vcf = $vcf->path;
	print STDERR "",$Analysis->get_id,"\t",$vcf,"\n";
	$Analysis->upload_vcf($vcf);
	}
