#/bin/bash

cd ../src
while true; do
	coffeetags -R -f TAGS
	echo "GENERATED TAGS"
	sleep 1
done
