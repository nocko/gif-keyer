#!/bin/bash

keyup_pic=keyup.jpg
keydown_pic=keydown.jpg

if [ ${#@} -ne 2 ]; then
    echo "Usage: keyer.sh <WPM> \"<phrase>\""
    exit 1
fi

wpm=$1
phrase=$(echo $2 |tr '[:upper:]' '[:lower:]')

short_delay=$(( 6000 / (50 * $wpm)  ))
long_delay=$(( $short_delay*3 ))
word_delay=$(( $short_delay*7 ))

declare -A map
map=([a]=.- [b]=-... [c]=-.-. [d]=-.. [e]=. [f]=..-. [g]=--. \
	[h]=.... [i]=.. [j]=.--- [k]=-.- [l]=.-.. [m]=-- \
	[n]=-. [o]=--- [p]=.--. [q]=--.- [r]=.-. [s]=... \
	[t]=- [u]=..- [v]=...- [w]=.-- [x]=-..- [y]=-.-- \
	[z]=--..)

conv_args="-dispose none -delay 0 $keyup_pic"
for (( i=0; i<${#phrase}; i++ )); do
    char=${phrase:$i:1}
    if [ -z ${map[$char]} ]; then
	conv_args="$conv_args ( -delay $word_delay placeholder.png ) "
    fi
    for (( j=0; j<${#map[$char]}; j++ )); do
	symbol=${map[$char]:$j:1}
	if [ ${symbol}x == ".x" ]; then
	    conv_args="$conv_args ( -delay $short_delay -dispose previous $keydown_pic"
	elif [ ${symbol}x == "-x" ]; then
	    conv_args="$conv_args ( -delay $long_delay -dispose previous $keydown_pic"
	fi
	if [ ${j} == $(expr ${#map[$char]} - 1) ]; then
	     conv_args="$conv_args -delay $long_delay placeholder.png )"
	else
	     conv_args="$conv_args -delay $short_delay placeholder.png )"
	fi
    done
done
if [ ! -z $KEYER_STDOUT ]; then
    outfile="gif:-"
else
    outfile=output.gif
fi
exec convert -loop 1 $conv_args $outfile
