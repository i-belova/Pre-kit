use strict;
use warnings;
use Data::Dumper;
use List::Util qw(max);

open (READ, "<CRDB");

my $header = <READ>;
chomp $header;
$header = [split/\t/, $header];
my %col_to_disease;
my %data;
my @diseases;
for (my $i = 3; $i < scalar (@{$header}); $i++) {
	$col_to_disease{$i} = $header->[$i];
	$data{$header->[$i]} = {};
	push @diseases, $header->[$i];
	}

my %genes;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	for (my $i = 3; $i < scalar(@mas); $i++) {
		if (defined ($data{$col_to_disease{$i}}->{$mas[0]})) {
			$data{$col_to_disease{$i}}->{$mas[0]} = max($mas[$i], $data{$col_to_disease{$i}}->{$mas[0]});
			} else {
			$data{$col_to_disease{$i}}->{$mas[0]} = $mas[$i];
			}
		}
	$genes{$mas[0]} = 1;
	}

close READ;

print "GENE";
for (my $i = 0; $i < scalar(@diseases); $i++) {
	print "\t$diseases[$i]";
	}
print "\n";

foreach my $gene (keys %genes) {
	print $gene;
	for (my $i = 0; $i < scalar(@diseases); $i++) {
		print "\t".$data{$diseases[$i]}->{$gene};
		}
	print "\n";
	}















