use strict;
use warnings;

my $organ = $ARGV[0];

open (READ, "<base");

my @names;
while (<READ>) {
	chomp;
	my @mas = split/\t/;
	$mas[1] = join(" ", grep {defined} @mas[1..(scalar @mas)]);
	my $name;
	if ($mas[1] eq 'HP') {
		open (HP, "<cancer_hotspots.tsv");

		while (<HP>) {
			chomp;
			my @hp = split/\t/;
			next if $hp[0] ne $mas[0];
			my $ref;
			my $pos = $hp[1];
			my $alt;
			if ($hp[3] =~ /(\S+):/) {
				$alt = $1
				}
			if ($hp[2] =~ /(\S+):/) {
				$ref = $1;
				}
			if ($hp[4] =~ /$organ:/) {
				push @names, "$mas[0] $ref$pos codon mutation";
				}
			}

		close HP;
		push @names, "$mas[0] non-hotspot mutation predicted to be oncogenic";
		} elsif ($mas[1] eq 'CDS') {
		push @names, "$mas[0] NULL mutation";
		} else {
		push @names, "$mas[0] $mas[1]";
		}
	}

close READ;

foreach my $arg (@names) {
	print "INSERT INTO main (disease, name, rating, votes) VALUES ('".uc($ARGV[0])."', '$arg', 1000, 0);\n";
	}


