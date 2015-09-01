#!/bin/bash

if [ -z "$KEYUP_PIC" ]; then
    keyup_pic=keyup.jpg
else
    keyup_pic=$KEYUP_PIC
fi
if [ -z "$KEYDOWN_PIC" ]; then
    keydown_pic=${KEYUP_PIC%.*}.mpc
else
    keydown_pic=keydown.jpg
fi

# if [ ${#@} -lt 1 ]; then
#     >&2 echo "Usage: keyer.sh \"<phrase>\" [output.gif]"
#     exit
# fi

if [ -z "$KEYER_WPM" ]; then
    KEYER_WPM="13"
fi
if [ -z "$KEYER_OUTPUT" ]; then
    if [ ! -z "$2" ]; then
	KEYER_OUTPUT=$2
    else
	KEYER_OUTPUT=output.gif
    fi
fi

phrase=$(echo $1 |tr '[:upper:]' '[:lower:]')

short_delay=$(( 6000 / (50 * $KEYER_WPM)  ))
long_delay=$(( $short_delay*3 ))
word_delay=$(( $short_delay*7 ))

if [ ! -z "$KEYER_DEBUG" ]; then
    (
	echo "WPM: $KEYER_WPM"
	echo "Dit: $short_delay"
	echo "Dah: $long_delay"
	echo "Break: $word_delay"
	echo "Phrase: $phrase"
    ) >&2 
fi

declare -A map
map=([a]=.- [b]=-... [c]=-.-. [d]=-.. [e]=. [f]=..-. [g]=--. \
	[h]=.... [i]=.. [j]=.--- [k]=-.- [l]=.-.. [m]=-- \
	[n]=-. [o]=--- [p]=.--. [q]=--.- [r]=.-. [s]=... \
	[t]=- [u]=..- [v]=...- [w]=.-- [x]=-..- [y]=-.-- \
	[z]=--.. [0]=----- [1]=.---- [2]=..--- [3]=...-- \
	[4]=....- [5]=..... [6]=-.... [7]=--... [8]=---.. \
	[9]=----.)

conv_args="convert -limit map 8 -limit memory 8 -loop 1 -dispose none -delay 0 $keyup_pic"
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

if [ ! -z "$KEYER_WEB" ]; then
    # In 'web mode' we output to stdout and cache file
    if [ ! -d gifs/$KEYER_WPM ]; then
	mkdir -p gifs/$KEYER_WPM
    fi
    conv_args="$conv_args gif:-"
    exec $conv_args | tee "gifs/$KEYER_WPM/$KEYER_OUTPUT"
else
    conv_args="$conv_args $KEYER_OUTPUT"
    exec $conv_args
fi
