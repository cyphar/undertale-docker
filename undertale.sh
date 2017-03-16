#!/bin/zsh
# undertale-docker: running UNDERTALE in a Docker container
# Copyright (C) 2017 Aleksa Sarai
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

set -ex

# What does this do? Lots of magic, don't ask me. I copied from the _best_
# source of information on the internet, especially on the topic of container
# technologies. https://stackoverflow.com/a/25280523
XAUTH=$(mktemp --tmpdir docker-xauth.XXXXXX)
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Make sure we have UNDERTALE_linux set up.
mkdir -p $HOME/.config/UNDERTALE_linux
chmod 0777 $HOME/.config/UNDERTALE_linux

# Figure out what the audio group is.
audio_gids=( "$(find /dev/snd/ -type c | xargs stat -c "%g" | sort -u)" )
[[ "${#audio_gids[@]}" == 1 ]] || exit 1
audio="${audio_gids[1]}"
[[ "${audio}" != "" ]] || exit 1

# Run UNDERTALE. Stay determined!
# XXX: Can this work with rootless containers?
docker run -it --rm -u "chara:$audio" \
	-v $HOME/.config/UNDERTALE_linux:/home/chara/.config/UNDERTALE_linux:rw \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	-e DISPLAY=unix$DISPLAY \
	-v $XAUTH:$XAUTH:ro \
	-e XAUTHORITY=$XAUTH \
	--device /dev/snd:/dev/snd:rwm \
	--net none \
	cyphar/undertale || :

# Clean up somewhat.
rm -f $XAUTH
