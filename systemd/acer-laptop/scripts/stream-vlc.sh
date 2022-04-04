#!/bin/bash

cvlc -vvv pulse:// '#transcode{acodec=mp3,ab=320,channels=2,samplerate=48000}:standard{access=http,dst:localhost:6081/pc.mp3}'

