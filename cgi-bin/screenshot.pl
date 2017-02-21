#!/usr/local/bin/perl
use Time::Local;
use POSIX;
my $currenttime = strftime('%F %T',localtime(time()));;
my $onlinelist="/exec/apps/bin/fablots/bin/host.list";
my @host;
open(LIST,'<',"$onlinelist")||die "can't open online list";
while($line=<LIST>){
next if $line!~/b/;
next if $line=~/750|MST|FLX|LTK|-/;
my @tester=split(/\|/,$line);
$tester[0]=~s/\s//g;
push @host,$tester[0];
}
close LIST;
my $timeout=6;
print "----------------Start----$currenttime----\n";
foreach $host(@host){
$host=~/b3(\w{0,4})[0-9]{2}/;
my $platform=uc($1);
my $p=`ping $host -c 1`;
$p=~/(.w*)% packet loss/;
if ($1 <= 10 ){
print "shotscreen on $host---->";
eval{
local $SIG{ALRM} = sub { die "time out\n" };
alarm $timeout;
system('xwd -root -silent -display '.$host.':0 | xwdtopnm | pnmtojpeg>/probeeng/bat3eng/RealView/'.$platform.'/'.uc($host).'.jpeg');
alarm (0);
};
}
}
print "------------------End-------------------\n";
