#!/usr/local/bin/perl
use Data::Dumper;
use POSIX;
use Time::Local;
use JSON;
use CGI;
use CGI::Session::Driver::file;
use CGI::Session;
use CGI qw(:standard);
use Net::LDAP;
my $cgi = new CGI;
my $session=CGI::Session->new("driver:db_file",$cgi,{Directory=>'/cgisession/RealView'});
 $session->expire("30m");
my $cookie=$cgi->cookie(CGISESSID=>$session->id);
my $in_user=param('username');
my $user_pw=param('password');
$in_user =~ s/\s//g;
my @ignore_user=('b04223','r65989');
$ldaps_url = 'ldaps://fsl-ids.freescale.net:636';	# SSL 
$ldap = Net::LDAP->new( $ldaps_url ) or die "999:$! ($@)\n";
$user_dn = "motguid=".$in_user.",ou=people,ou=intranet,dc=motorola,dc=com";
$mesg = $ldap->bind( $user_dn, password => $user_pw );
if ($mesg->code==0){
$session->param("user",uc($in_user));
#print "window.location.href='http://zch01app04v.ap.freescale.net/PPCMS/index.html';\n";
#$session->param("userSessionPwd",$user_pw);
}
print $cgi->header(-cookie=>$cookie);
my %output;
$output{success} = $mesg->error;
$output{results} = $mesg->code;
foreach my $match (@ignore_user){
$output{results}="permission denied" if $match=~/$in_user/;
}
my $json = to_json(\%output);
print "$json";
$ldap->unbind;
exit 0;
