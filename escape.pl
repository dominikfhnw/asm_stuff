#!/usr/bin/perl
BEGIN {
	my $d = !!$ENV{DEBUG};
	*DEBUG = sub(){ $d };
}

#use v5.34;
#no warnings qw( experimental::smartmatch );
sub say{local$\="\n";print@_}

my $REPLACE = 1;
if($ARGV[0] eq "-n"){
	shift @ARGV;
	say "NOREPLACE";
	$REPLACE = 0;
}

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
my %eorig = %escape;
$escape{37} = "%%";
my $file = do { local $/; <> };

sub dbg {
	say STDERR @_ if DEBUG;
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

sub escstr2 {
	my $in = shift;
	my $out = "";

	for(0..length($in)-1){
		my $cord = ord(substr($in, $_, 1));
		my $next = substr($in, $_+1, 1);
		
		$out .= esc2($cord, $next);
	}
	return $out;
}

sub escstr {
	my $in = shift;
	my $f  = shift;

dbg "ESCSTR $f";
	my $out = "";

	for(0..length($in)-1){
		my $cord = ord(substr($in, $_, 1));
		my $next = substr($in, $_+1, 1);
		
		$out .= esc3($cord, $next, $f);
	}
	return $out;
}


my $out;
#$escape{37} = '%%';
#use Data::Dumper; dbg Dumper(\%escape);
my %freq;
my %freq2;

for(split//,$file){
	$freq{ord()}++;
}

my $input_length = length($file);
say "Input: ",$input_length;
my $i;
my $FIRST = 0x21;
dbg "FREQUENCY LIST:";
foreach my $name (sort keys %freq) {
	my $e = esc3($name,);
	my $len = length($e);
	my $freq = $freq{$name};
	my $saving = ($freq * ($len-1)) - 1 - $len;
	#dbg "$name $saving";
	dbg "$name ",esc3($name),": $saving";
	$freq2{$name} = $saving;
}

if(DEBUG){
dbg "top30";
	foreach my $name (reverse sort { $freq{$a} <=> $freq{$b} } sort keys %freq) {
		dbg "$name ",esc3($name),": ",$freq{$name} || 0;
		$i++;
		#last if $i > 30;
	}
dbg "end top30";
}
#@unused;
$i = 0;

for(A..Z){
	$_ = ord;
	if($freq{$_} == 0){
		dbg "$_ ",esc2($_),": ",$freq{$_} || 0;
		push @unused, $_;
		$i++;
		#last if $i > 10;
	}
}

for(a..z){
	$_ = ord;
	if($freq{$_} == 0){
		dbg "$_ ",esc2($_),": ",$freq{$_} || 0;
		push @unused, $_;
		$i++;
		#last if $i > 10;
	}
}

dbg "UNUSED: ",scalar(@unused)," ",join "",map chr,@unused;
my $PRE, $POST;
#say Dumper \%freq;
my $zero = 0;
my $fmts = 1;
#if($freq{37} > 5){
#	$fmts = 0;
#}
#if($freq{0} > 9){
#	$zero = 1;
#}
dbg "FFF 0 $freq{0} % $freq{37}";
#dbg "FFF ", scalar(@unused);
#use Data::Dumper;
#dbg Dumper(\@unused);
my $replace1 = "";
my $replace2 = "";


sub repl {
	if(scalar @unused > 0){
		my $input = shift;
		my $chr = chr(shift @unused);
		$replace1 .= $chr;
		$replace2 .= chr($input);
		$escape{$input} = $chr;
		#$POST = "|tr $replace1 '".escstr($replace2,0)."'";
		$POST = "|tr $replace1 '".escstr($replace2,0)."'";
	}
}

my $totalsaving = 0;
foreach my $name (reverse sort { $freq2{$a} <=> $freq2{$b} } sort keys %freq2) {
	if($freq2{$name} > 0){
		dbg "SAVE $name ",esc2($name)," $freq2{$name}";
		$totalsaving += $freq2{$name};
		repl($name) if $REPLACE;
	}
}


dbg "XXX ",escstr2($replace2);
dbg "XXX ",escstr($replace2,1);
dbg "XXX ",escstr($replace2,0);

$out = escstr($file,1);
#for(0..length($file)-1){
#	my $cord = ord(substr($file, $_, 1));
#	#my $curr = substr($file, $_, 1);
#	my $next = substr($file, $_+1, 1);
#	
#	$out .= esc3($cord, $next);
#
#}
#
$out = "printf $PRE'$out'$POST";
my $output_length = length($out);
say "Output: ",$output_length;
say "Relative: ",int(100*$output_length/$input_length),"%";
dbg "TOTALSAVING: ",$totalsaving-7;
print "$out>${ARGV}b\ncmp -l $ARGV ${ARGV}b\n";

sub esc3 {
	my $cord = shift;
	my $next = shift;
	my $f = shift;
	my $curr = chr $cord;

	my $out = "";
#dbg "ESC3 $f";

	if($cord == 39){
		$out .= esc($cord, $next);
	}
	elsif($f ? $escape{$cord} : $eorig{$cord}){
		#dbg "ESC $cord";
		if($cord == 7 and $next !~ /[0-7]/){
			$out .= esc($cord, $next);
		}
		else{
			$out .= $f ? $escape{$cord} : $eorig{$cord};
		}
	}
	elsif ($cord >= $FIRST && $cord < 0x7f) {
		$out .= $curr;
	}
	else{
		$out .= esc($cord, $next);
	}

	return $out;

}
sub esc2 {
	my $in = shift;
	my $next = shift;

	if($in == 39){
		return esc($in, $next);
	}
	if ($in >= $FIRST && $in < 0x7f) {
		return chr $in;
	}
	return esc($in, $next);
}

