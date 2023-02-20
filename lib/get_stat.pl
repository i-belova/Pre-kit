use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;
use Data::Dumper;

my %CRDB;
open (READ, "<CRDB_by_gene");
my @head = qw(GENE BREAST OVARY NSCLC COADREAD PRAD PAAD STAD UTERUS SKCM CHOL BLADDER SOFT_TISSUE SACA BRAIN CERVIX GINET);
my $aksdjfashkfj = <READ>;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	$CRDB{$mas[0]} = {};
	for (my $i = 1; $i < scalar @head; $i++) {
		$CRDB{$mas[0]}->{$head[$i]} = $mas[$i];
		}
	}

close READ;

my $DB = AODDB->fast_connect();

my %LoE;
$LoE{1} = 10;
$LoE{'2A'} = 9;
$LoE{2} = 8;
$LoE{'2B'} = 7;
$LoE{'3A'} = 6;
$LoE{'3B'} = 5;
$LoE{'3C'} = 4;
$LoE{'3'} = 3;
$LoE{'4'} = 2;


my $CI_count = 0;
foreach my $Case ($DB->cases) {
	next unless defined $Case->ClinicalInterpretation;
	next unless defined $Case->BaselineStatus->info->{pathologycodebaseline};
	#next unless $Case->info->{casename} eq '36932-01';
	my $CI = $Case->ClinicalInterpretation;
	my $template = {};
	$template = $CI->report_evaluate_TMB($template);
	next if $template->{TMB} > 10;

	my $code = $Case->BaselineStatus->info->{pathologycodebaseline};
	my $path = $DB->Pathology($code)->info->{'pathologypath'};
	my $CRDB_code;
	foreach my $arg (@head) {
		my $name = lc($arg);
		if (lc($path) =~ /\.$name\./) {
			$CRDB_code = $arg;
			last;
			}
		}
	next unless defined $CRDB_code;

	my %mutations;
	my %cnvs;
	my $is_complex = 0;
	foreach my $Barcode ($Case->barcodes) {
		my $AN = $Barcode->major_AN;
		next unless defined $Barcode->info->{panelcode};
		if ((uc($Barcode->info->{panelcode}) eq 'CCP') or (uc($Barcode->info->{panelcode}) eq 'OCAV3')) {
			$is_complex = 1;
			}
		next unless defined $AN;
		foreach my $MutationResult ($AN->mutationResults) {
			next unless defined $MutationResult->info->{zygositycurated};
			next if $MutationResult->info->{zygositycurated} =~ /wt/;
			my $Mutation = $DB->Mutation($MutationResult->info->{mutationid});
			$mutations{$Mutation->name} = $MutationResult->info->{zygositycurated};
			}
		}
	next if $is_complex eq 0;
	print $CI->get_id,"\t",$template->{TMB},"\t$CRDB_code\t$is_complex\n";
	next;

	++$CI_count;
	foreach my $mutation_name (keys %mutations) {
		next unless defined $DB->Mutation($mutation_name)->VariantAnnotation;
		my $gene_symbol = $DB->Mutation($mutation_name)->VariantAnnotation->Transcript->Gene->info->{'genesymbol'};
		#print "$mutation_name\t$mutations{$mutation_name}\t$gene_symbol\n";
		my $MT = Table::MolecularTarget->forceFetch($DB, "$mutation_name:$mutations{$mutation_name}");
		my $dbh = $DB->{mysql};
		my $sql_cmd = "select confidenceLevel from `RecommendationTP` where clinicalInterpretationId = '".$CI->get_id."' and molecularTargetId = '".$MT->get_id."';";
		my $sth;
		$sth = $dbh->prepare($sql_cmd) or return 1;
		eval {$sth->execute};
		my $max;
		my $max_loe;
		if ($@) {
			die;
			} else {
			while (my $row = $sth->fetchrow_arrayref) {
				next if uc($$row[0]) eq 'R1';
				next if uc($$row[0]) eq 'R2';
				next if uc($$row[0]) eq 'R';
				
				unless (defined $max) {
					$max = uc($$row[0]);
					$max_loe = $LoE{$max}
					} elsif ($LoE{uc($$row[0])} > $max_loe) {
					$max = uc($$row[0]);
					$max_loe = $LoE{$max}
					}
				}
			}
		next unless defined $max;
		print "",$CI->get_id,"\t$CRDB_code\t$mutation_name\t$gene_symbol\t$max\t";
		print "",($CRDB{$gene_symbol} ? $CRDB{$gene_symbol}->{$CRDB_code} : 'NA'),"\n";
		delete $mutations{$mutation_name};
		}
	
	foreach my $mutation_name (keys %mutations) {
		next unless defined $DB->Mutation($mutation_name)->VariantAnnotation;
		my $gene_symbol = $DB->Mutation($mutation_name)->VariantAnnotation->Transcript->Gene->info->{'genesymbol'};
		my $MT = Table::MolecularTarget->forceFetch($DB, "$mutation_name:$mutations{$mutation_name}");
		my $dbh = $DB->{mysql};
		my $sql_cmd = "select NCTid from `RecommendationCT` where clinicalInterpretationId = '".$CI->get_id."' and molecularTargetId = '".$MT->get_id."';";
		my $sth;
		$sth = $dbh->prepare($sql_cmd) or return 1;
		eval {$sth->execute};
		my $count = 0;
		if ($@) {
			die;
			} else {
				while (my $row = $sth->fetchrow_arrayref) {
					++$count;
					}
				}
		next if $count eq 0;
		print "",$CI->get_id,"\t$CRDB_code\t$mutation_name\t$gene_symbol\tCT\t";
		print "",($CRDB{$gene_symbol} ? $CRDB{$gene_symbol}->{$CRDB_code} : 'NA'),"\n";
		delete $mutations{$mutation_name};
		}
	}

print "TOTAL - $CI_count\n";




















