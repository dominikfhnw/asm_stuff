#!/usr/bin/perl
#use v5.34;
#no warnings qw( experimental::smartmatch );
my $file = do { local $/; <> };
sub say{local$\="\n";print@_}

sub dbg {
	say STDERR @_ if 1;
}

sub esc2 {
	my $in = shift;
	my $next = shift;

	if ($in >= 0x20 && $in < 0x7f) {
		return chr $in;
	}
	return esc($in);
}

sub esc {
	my $in = shift;
	my $next = shift;

	if($next =~ /[0-7]/){
		return sprintf "\\%03o",$in;
	}
	else{
		return sprintf "\\%o",$in;
	}

}

my $out;
my %escape = qw(
	7	\a
	8	\b
	27	\e
	12	\f
	10	\n
	13	\r
	9	\t
	11	\v
	92	\\\
);
#use Data::Dumper; dbg Dumper(\%escape);
my %freq;

for(split//,$file){
	$freq{ord()}++;
}

dbg "TOTAL: ",length($file);
my $i;
foreach my $name (reverse sort { $freq{$a} <=> $freq{$b} } keys %freq) {
	dbg "$name ",esc2($name),": ",$freq{$name} || 0;
	$i++;
	last if $i > 10;
}
@unused;
$i = 0;
for(a..z){
	$_ = ord;
	if($freq{$_} == 0){
		dbg "$_ ",esc2($_),": ",$freq{$_} || 0;
		push @unused, $_;
		$i++;
		last if $i > 10;
	}
}
for(A..Z){
	$_ = ord;
	if($freq{$_} == 0){
		dbg "$_ ",esc2($_),": ",$freq{$_} || 0;
		push @unused, $_;
		$i++;
		last if $i > 10;
	}
}
my $PRE, $POST;
#say Dumper \%freq;
my $zero = 0;
my $fmts = 1;
if($freq{37} > 5){
	$fmts = 0;
}
if($freq{0} > 9){
	$zero = 1;
}
dbg "FFF 0 $freq{0} % $freq{37}";
#dbg "FFF ", scalar(@unused);
#use Data::Dumper;
#dbg Dumper(\@unused);
if($zero){
	if(@unused > 0){
		$escape{0} = chr($unused[0]);
		$POST = "|tr $escape{0} '\\0'";
		$POST = "|tr $escape{0} \\\\0";
	}
	else {
		dbg "TURNING OFF ZERO";
	}
}
if($fmts){
	$escape{37} = '%%';
}
else {
	$PRE = "'%s' ";
}

for(0..length($file)-1){
	my $cord = ord(substr($file, $_, 1));
	my $curr = substr($file, $_, 1);
	my $next = substr($file, $_+1, 1);
	
	#dbg "F $cord";

	if($cord == 39){
		$out .= esc($cord, $next);
	}
	elsif($escape{$cord}){
		#dbg "ESC $cord";
		if($cord == 7 and $next !~ /[0-7]/){
			#dbg "07 NO DIG";
			#$out .= "\\".$escape{$cord};
			#$out .= sprintf "\\%o",$cord;
			$out .= esc($cord, $next);
		}
		else{
			$out .= $escape{$cord};
		}
	}
	elsif ($cord >= 0x20 && $cord < 0x7f) {
		$out .= $curr;
	}
	#elsif($next =~ /[0-7]/){
	#	$out .= sprintf "\\%03o",$cord;
	#}
	else{
		$out .= esc($cord, $next);
	}
}

$out = "printf $PRE'$out'$POST";
dbg "OUT: ",length($out);
print "$out>${ARGV}b\ncmp -l $ARGV ${ARGV}b\n";
