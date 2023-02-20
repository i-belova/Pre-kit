use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;

my $DB = AODDB->fast_connect();

open (READ, "<oncogene");

while (<READ>) {
	chomp;
	my $Mutation = $DB->Mutation($_);
	print "$_\t",$Mutation->VariantAnnotation->info->{hgvsp},"\n";
	}

close READ;
