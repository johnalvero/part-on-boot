#!/bin/bash

part_hash=$(cat part.sh | gzip | base64)
scheme_hash=$(cat scheme.txt | gzip | base64)


sed "s|_part_|$part_hash|" user-data.tmpl | sed "s|_scheme_|$scheme_hash|" 
