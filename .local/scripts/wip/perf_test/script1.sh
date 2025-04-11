i=0
while [ "$i" -lt 100000 ]; do
	i=$((i + 1))
	echo "$i" >/dev/null
done
