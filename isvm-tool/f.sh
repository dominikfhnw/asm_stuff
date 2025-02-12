for i in $(seq 0 35);do
	
	./cpuf $(seq $i);echo $i $?

done

