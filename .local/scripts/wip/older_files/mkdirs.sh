#!/bin/bash
foo() {

	artist=$(grep "^artist=" "${f%.wma}"_meta2.txt | sed s/artist=//)
	album=$(grep "^album=" "${f%.wma}"_meta2.txt | sed s/album=//)

	LOSSY="lossy"
	LOSSYA=$LOSSY/$artist
	LOSSYDIR=$LOSSYA/$album

	if [ ! -d "$LOSSYDIR" ]; then
		mkdir -p "$LOSSYDIR"
	fi

	rm -f ${f%.wma}_met*.txt
	echo ${f%.wma}_met*.txt

}

for f in *.wma; do
	foo "$f" &
done

wait
