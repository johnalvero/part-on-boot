#!/bin/bash

if [ "$#" -ne 1 ]
then
        echo "Usage: $0 <centos major version e.g. 6>"
        exit
fi

part_hash=$(cat part.sh | gzip | base64)
scheme_hash=$(cat scheme.txt | gzip | base64)


if [ "$1" -eq "7" ]
then
	mytemplate=user-data-7.tmpl
elif [ "$1" -eq "6" ]
then
	mytemplate=user-data-6.tmpl
else
	echo "invalid centos version"
fi

sed "s|_part_|$part_hash|" $mytemplate | sed "s|_scheme_|$scheme_hash|" 
