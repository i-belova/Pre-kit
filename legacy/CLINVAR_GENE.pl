#perl CLINVAR_GENE.pl BRCA1 | sort -k2 -n
use strict;
use warnings;
use List::Util qw[min max];
use Env;
use lib $ENV{AODADMIN};
use Aoddb;
use Atlas;

my $DB = AODDB->fast_connect();

my $GENE = $DB->Gene($ARGV[0]);
my $geneString = $GENE->info->{genesymbol}.":".$GENE->info->{ezgeneid};


       while (<CLINVAR>) {
                next if m!#!;
                my $line = $_;
                my @mas = split/\t/;
                my @info = split/;/, $mas[7];
                next unless defined Atlas::VCFinfo($line, "GENEINFO");
                next unless defined Atlas::VCFinfo($line, "CLNSIG");
                next unless defined Atlas::VCFinfo($line, "MC");
                next unless Atlas::VCFinfo($line, "GENEINFO") eq $geneString;
		next unless Atlas::VCFinfo($line, "CLNSIG") =~ /Pathogenic/;
		my @freq;
		if (defined(Atlas::VCFinfo($mas[7], "AF_ESP"))) {
			push (@freq, Atlas::VCFinfo($mas[7], "AF_ESP"));
			}
		if (defined(Atlas::VCFinfo($mas[7], "AF_EXAC"))) {
			push (@freq, Atlas::VCFinfo($mas[7], "AF_EXAC"));
			}
		#if (defined(Atlas::VCFinfo($mas[7], "AF_TGP"))) {
		#	push (@freq, Atlas::VCFinfo($mas[7], "AF_TGP"));
		#	}
		if (scalar(@freq) >= 1) {
			print "",Atlas::VCFinfo($line, "RS"),"\t",max(@freq),"\n";
			}
		next;
		#next unless ((Atlas::VCFinfo($line, "MC") =~ /nonsense/) or (Atlas::VCFinfo($line, "MC") =~ /frameshift_variant/));
                print STDERR "!$line\n";
                #push (@pathogenic_pos)
                }

        close CLINVAR;














