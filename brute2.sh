#for i in $(seq 0 255);do printf -v x "%x" $i;echo "** $x";printf "\x$x\x20\x00\x01\x00" |ndisasm -u -;done

#for i in $(seq 0 16 255);do
#for i in $(seq 0 255);do


for i in $(seq 32 126);do
	printf -v x "%x" $i

	#out=$(printf "\x$x\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90" |ndisasm -u -)
	out=$(printf "\x26\x31\x$x\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90" |ndisasm -u -)
	case $out in
	*db\ 0x*) : ;;
	#*\[*) : ;;
	#*\[eax\]*,*)
	#	: echo bork
	#	;;
	*)
		#echo "** $x $y"
		a=$(echo "$out" | grep -v "nop" | wc -l)
		if [ "$a" -eq 1 ]; then
			echo "$out" | grep -v "nop"
		fi
		;;
	esac

	for j in $(seq 32 126);do
		printf -v y "%x" $j
		#out=$(printf "\x28\x$x\x90\x90\x90\x90\x90\x90" |ndisasm -u -)
		#out=$(printf "\x$x\x$y\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90" |ndisasm -u -)
		out=$(printf "\x26\x31\x$x\x$y\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90" |ndisasm -u -)
		#out=$(printf "\x24\x$x\x90\x90\x90\x90\x90\x90" |ndisasm -u -)

		#out=$(printf "\x$x\x20\x00\x01\x00" |ndisasm -u -)
		#out=$(printf "\x$x\x04\x00\x00\x00" |ndisasm -u -)
		#out=$(printf "\x$x" |ndisasm -u -)
		#out=$(printf "\x$x\xae\x90\x90\x90\x90" |ndisasm -u -)
		#out=$(printf "\x$x\xc1\xeb\x04" |ndisasm -u -)

		#out=$(printf "\x04\x00\x00\x00\x$x" |ndisasm -u -)
		#out=$(printf "\x0f\x$x\x04\x00\x00\x00" |ndisasm -u -)
		#out=$(printf "\x00\x$x\x00\xff\xff" |ndisasm -u -)
		#:<<-'#COMMENT'
		case $out in
		#*db\ 0x00*)
		#*shr*)
		#	:;;
		\ *[cdefgs]s\ *) : ;;
		*db\ 0x*) : ;;
		#*\[*) : ;;
		#*\[eax\]*,*)
		#	: echo bork
		#	;;
		*)
			#echo "** $x $y"
			a=$(echo "$out" | grep -v "nop" | wc -l)
			if [ "$a" -eq 1 ]; then
				echo "$out" | grep -v "nop"
			fi
			;;
		esac
		#COMMENT
		#echo "** $x"
		#echo "$out"
	done			
done 

