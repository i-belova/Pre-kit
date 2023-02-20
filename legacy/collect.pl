use strict;
use warnings;
use Env;
use lib $ENV{AODADMIN};
use Aoddb;
use Atlas;
use Data::Dumper;
use List::Util qw[min max sum];

my $panel = $ARGV[0];
$panel = 'AODABCV1' unless defined $panel;

my $DB = AODDB->fast_connect();

my %dic; map {$dic{$_} = 1} qw(87 88 89 90 91 92);
foreach my $Barcode ($DB->barcodes) {
	next unless defined $Barcode->info->{panelcode};
	#next if uc($Barcode->info->{panelcode}) ne 'RCMGLYNCHV1';
	next if uc($Barcode->info->{panelcode}) ne $panel;
	my $date;
	next unless defined $Barcode->Run;
	$date = $Barcode->Run->info->{sequencingrundate};
	next unless defined $date;
	#next if $date ne '2018-06-04';
	#next if ($date cmp '2020-03-19') eq '-1';
	#next unless defined $dic{$Barcode->Run->get_id};
	my $file = $Barcode->get_folder . "/QC.json";
	if (open(TEMPFILE, "<$file")) {
		close TEMPFILE;
		} else {
		next;
		}
	print STDOUT "",$Barcode->get_id,"\t",$Barcode->Run->get_id,"\t",($Barcode->Case->InternalBarcode ? $Barcode->Case->InternalBarcode->get_id : 'N/A'),"\t",($date || 'N/A'),"\t",$Barcode->bam->name,"\t",$Barcode->LibraryQC->info->{result},"\t",$Barcode->LibraryQC->info->{analysisversion};
	print STDOUT "\t",Atlas::file_to_json($file)->{"onTarget"};
	print STDOUT "\t",Atlas::file_to_json($file)->{"offTarget"};
	print STDOUT "\t",Atlas::file_to_json($file)->{"poolDisbalanceE"};
	print STDOUT "\t",Atlas::file_to_json($file)->{"poolDisbalanceC"};
	print STDOUT "\t",(Atlas::file_to_json($file)->{"sensActionable"} || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"sensHotspot"} || 'N/A');
	print STDOUT "\t",Atlas::file_to_json($file)->{"below20"};
	#print STDOUT "\t",Atlas::file_to_json($file)->{"onTarget"};
	print STDOUT "\t",round(min(map {Atlas::file_to_json($file)->{"pool"}->[$_] ? Atlas::file_to_json($file)->{"pool"}->[$_]->[1] : ()} qw(0 1 2 3)));
	print STDOUT "\t",round(min(map {Atlas::file_to_json($file)->{"pool"}->[$_] ? Atlas::file_to_json($file)->{"pool"}->[$_]->[2] : ()} qw(0 1 2 3)));
	print STDOUT "\t",Atlas::file_to_json($file)->{"pool"}->[0]->[1];
	print STDOUT "\t",Atlas::file_to_json($file)->{"pool"}->[0]->[2];
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[1]->[1] || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[1]->[2] || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[2]->[1] || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[2]->[2] || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[3]->[1] || 'N/A');
	print STDOUT "\t",(Atlas::file_to_json($file)->{"pool"}->[3]->[2] || 'N/A');
	print STDOUT "\n";
	}


sub round {
        my $value = shift;
        my $digit = shift;
        $digit = 3 unless defined $digit;
        $digit = 10**$digit;
        return (int($value*$digit)/$digit);
        }









