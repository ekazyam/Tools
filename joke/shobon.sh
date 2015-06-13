#!/bin/bash

AA=('(´・ω・｀)' '(　´・ω・)' '(　´・ω)' '(　　　　　)' '(ω・｀　)' '(・ω・｀　)' '(´・ω・｀)')
for (( Z = 0; Z < ${#AA[@]}; ++Z ))
do
	clear
	echo ${AA[$Z]}
	sleep 0.5s;
done
clear

