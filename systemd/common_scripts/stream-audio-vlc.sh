#!/bin/bash
# usage: stream-audio-vlc.sh BITRATE HOST PORT
arg_bitrate="$1"
arg_host="$2"
arg_port="$3"

audio_monitor=$(pacmd list-sources | awk '/name:.+\.monitor/' | cut -d'<' -f 2)
audio_monitor=${audio_monitor%>*}
transcode_format="acodec=mp3,ab=$arg_bitrate,channels=2,samplerate=48000"
stream_output="dst=$arg_host:$arg_port/pc.mp3"

cvlc -vvv \
	pulse://$audio_monitor \
	:sout=#"transcode{$transcode_format}":http{$stream_output} \
	:no-sout-all \
	:sout-keep
