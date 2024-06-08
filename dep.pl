#!/usr/bin/perl
use warnings;
use strict;

my $file = $ARGV[0];
my $name = $ARGV[1] || 'root';

sub recurse {
	my $dot = shift;
	my $name = shift;
	my $start = shift;

	open my $fh, '<', $file || die;
	while(<$fh>){
		/^(\.+) (.*)/;
		next if $. < $start;
		my $f = length $1;
		if($f == 1+$dot){
			print "$2 $name\n";
			recurse(1+$dot, $2, 1+$.);
		}elsif($f > $dot){
		}else{
			return;
		}
	}
}

recurse(0, $name, 0);
