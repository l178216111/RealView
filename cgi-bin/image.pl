#!/usr/bin/perl
use MIME::Lite;
use DBI;
use Data::Dumper;
use POSIX;
use Time::Local;
use JSON;
use CGI;
use CGI::Session;
use CGI qw(:standard);
use Net::LDAP;
print "Content-type: application/json\n\n";
my $cgi=new CGI;
my $platform=$cgi->param('platform');
my $part=$cgi->param('part');
my $imagedir="\/probeeng\/webadmin\/htdocs\/RealView\/image\/";
my $storage='/probeeng/webadmin/cgi-bin/floorview_linux/storage';
$platform=~ s/platform\=//g;
@platform=split(/\&/,$platform);
%Colors =
    (
               "No_setup" => "#F00078",
		"PMI_Wait" =>'#F00078',
               "Idle" => "#F0F0F0",
               "Offline" => "#BB3D00",
               "Online" => "#00FF00",
               "Loading_tester" => "orange",
               "Loading" => "#000bbb000",
               "Prober_setup" => "#F00078",
               "Lot_start" => "#F00078",
               "First_die" => "#F00078",
               "Moving" => "#F00078",
               "Downloading" => "orange",
               "Uploading" => "orange",
               "Testing" => "#00FF00",
               "Inking" => "#00FF00",
               "Operator_Assist" => "#eeee00",
               "Error" => "#eeee00",
               "Pause" => "#F00078",
		"Test_Stop"=>"#F00078",
		"Pre_PMI_Wait"=>"#F00078",
		"PMI_checking"=>"#F00078",
               "PMI_Due" => "#F00078",
               "CRT_Setup" => "orange",
               "Camera_Setup" => "orange",
               "Polishing" => "orange",
               "Executing_APTPA" => "orange",
               "Disconnected" => "#fff000000",
               "Lot_end" => "#fff000000",
               "Wafer_end" => "orange",
               "Maint" => "#FF8000",
               "EQP" => "#FF8000",
               "ENG" => "blue",
               "QUAL" => "orange",
               "OFFL" => "gray",
               "CARD" => "lavender",
               "VEND" => "#000888fff",
               "Pins_Down_Routine" => "orange"
    );
%EMS_Colors =
        (
                    "EQSETUP" => "saddlebrown",
		    "SETUP" =>"red",
                    "EQUPGRD" => "saddlebrown",
                    "EXPPRCE" => "blue",
                    "EXPPROC" => "blue",
                    "IDLE" => "#F0F0F0",
                    "NOOPER" => "white",
                    "NOPROD" => "#FF95CA",
                    "NOSUPP" => "deeppink",
                    "OFFLINE" => "saddlebrown",
                    "QUAL" => "yellow",
                    "RUNNING" => "#00FF00",
                    "SMCOMP" => "orange",
                    "SMMAINT" => "orange",
                    "SMQUAL" => "orange",
                    "UALARM" => "#F00078",
                    "UENGEVL" => "cyan",
                    "UFACIL" => "red",
                    "UMCLDWN" => "red",
                    "UMCOMP" => "red",
                    "UMPARTS" => "red",
                    "UMQUAL" => "red",
                    "UMREP" => "red",
                    "UNKN" => "lavender",
                    "NOPROD" => "pink"
        );
my $result_ref=&redstorage($part);
my %output;
#print Dumper($result_ref);
foreach my $string (@platform){
	$result_ref=&reddir($string,$result_ref);
      	my %unit=%$result_ref;
	$output{$string}=$unit{$string};
}
sub redstorage{
	my $part=shift;
	$part='.' if ($part eq "all");
	my $unit;
	open(STORAGE,$storage)||return "0";
	while($line=<STORAGE>){
		next if ($line!~ /$part/);
		my @storage=split(/\,/,$line);
		$storage[1]="T47" if ($line=~/3347\&26/);
		$storage[1]="A5" if ($line=~/A585/);
		$unit{$storage[1]}{$storage[2]}{status_evr}=$storage[3].'('.$storage[4].')';
		$unit{$storage[1]}{$storage[2]}{status_ems}=$storage[5];
		$unit{$storage[1]}{$storage[2]}{part}=$storage[6];
		$unit{$storage[1]}{$storage[2]}{remain}=$storage[7];
		$unit{$storage[1]}{$storage[2]}{lot}=$storage[8];
		$unit{$storage[1]}{$storage[2]}{wafer}=$storage[9];
		$unit{$storage[1]}{$storage[2]}{color_evr}=$Colors{$storage[3]};
		$unit{$storage[1]}{$storage[2]}{color_ems}=$EMS_Colors{$storage[5]};
	}
	close STORAGE;
	return \%unit;
}
sub reddir{
	my $platform=shift;
	my $unit=shift;
	opendir(INFDIR,$imagedir.$platform)||return "0";
	my @image = readdir(INFDIR);
	shift @image,".";
	shift @image,"..";
		foreach my $image (@image){
			my @stime=stat($imagedir.$platform.'/'.$image); 
			my $time=time()-$stime[9];
			next if($time>240);
			$image=~ /^.*([0-9]{2})\.\w{2,4}$/;	
			my $toolid="T$1S$platform";
			$toolid=~s/$1// if ($toolid=~/T\w{2}S(J)\w*/);
			#for INK no S like T05INK
			$toolid=~s/S// if($toolid=~/INK/);
			$toolid=~s/$1// if ($toolid=~/T\w{2}SFL(E)X/);
			$unit{$platform}{$toolid}{image}="./image/".$platform."/".$image if defined $unit{$platform}{$toolid};
		}
	return \%unit;
	}	
my $json=to_json(\%output);
#print Dumper(\%output);
print "$json";
