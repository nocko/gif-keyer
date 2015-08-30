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
map=([a]=sl [b]=lsss [c]=lsls [d]=lss [e]=s [f]=ssls [g]=lls \
	[h]=ssss [i]=ss [j]=slll [k]=lsl [l]=slss [m]=ll \
	[n]=ls [o]=lll [p]=slls [q]=llsl [r]=sls [s]=sss \
	[t]=l [u]=ssl [v]=sssl [w]=sll [x]=lssl [y]=lsll \
	[z]=llss)

conv_args="-delay $long_delay $keyup_pic"
for (( i=0; i<${#phrase}; i++ )); do
    char=${phrase:$i:1}
    if [ 0 -eq ${#map[$char]} ]; then
	conv_args="$conv_args ( -delay $word_delay -clone 0 ) "
    fi
    for (( j=0; j<${#map[$char]}; j++ )); do
	symbol=${map[$char]:$j:1}
	if [ ${symbol}x == "sx" ]; then
	    conv_args="$conv_args ( -delay $short_delay $keydown_pic "
	elif [ ${symbol}x == "lx" ]; then
	    conv_args="$conv_args ( -delay $long_delay $keydown_pic "
	fi
	if [ ${j} == $(expr ${#map[$char]} - 1) ]; then
	     conv_args="$conv_args -delay $long_delay -clone 0 )"
	else
	     conv_args="$conv_args -delay $short_delay -clone 0 )"
	fi
    done
done
convert -loop 1 $conv_args -layers Optimize output.gif
