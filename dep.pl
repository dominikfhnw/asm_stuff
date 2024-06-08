#!/usr/bin/perl
use warnings;
use strict;
use v5.39;
my $file = $ARGV[0];
my $name = $ARGV[1] || 'root';

sub recurse {
	my $dot = shift;
	my $name = shift;
	my $start = shift;
	my $spc = "\t"x$dot;
	#say STDERR "${spc}RECURSE $dot $start $name";

	open my $fh, '<', $file || die;
	while(<$fh>){
		/^(\.+) (.*)/;
		next if $. < $start;
		my $f = length $1;
		#say STDERR "${spc}LOOP $dot $. $f $2";
		if($f == 1+$dot){
			my $newname = $2;
			#my $nb = $newname;
			#$nb =~ s!.*/!!;
			#my $basename = $name;
			#$basename =~ s!.*/!!;
			#say STDERR "${spc}$nb";
			print "$newname $name\n";
			recurse(1+$dot, $newname, 1+$.);
		}elsif($f > $dot){
		}else{
			return;
		}
	}
}

recurse(0, $name, 0);
