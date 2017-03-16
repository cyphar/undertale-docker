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

# Run like so (adapted from jessfraz's chromium commands):
# % docker run -itd --rm -u chara:17 \
#            -v $HOME/.config/UNDERTALE_linux:/home/chara/.config/UNDERTALE_linux:rw \
#            -v /tmp/.X11-unix:/tmp/.X11-unix \
#            -e DISPLAY=unix$DISPLAY \
#            -v ~/.Xauthority:/home/chara/.Xauthority \
#            -e XAUTHORITY=/home/chara/.Xauthority \
#            --device /dev/snd:/dev/snd:rwm \
#            --net none \
#            cyphar/undertale

# It's a real shame this game isn't free software. Indie games like this
# are usually much better than the AAA crap you find, and the developers
# are usually much more reasonable people.

FROM ubuntu:16.04
LABEL maintainer "Aleksa Sarai <cyphar@cyphar.com>"

# The game is 32bit only, and requires gog-install to install. Also requires
# some patching to gog-install because Ubuntu's Python is outdated.
RUN dpkg --add-architecture i386 && \
	apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
		python3 \
		python3-pip && \
	pip3 install gog-install && \
		sed -Ei 's/«|»//g' $(which gog-install) && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Requirements defined on the game page on GOG.com.
RUN apt-get update -y && \
	apt-get install -y \
		libc6:i386 \
		libasound2:i386 \
		libasound2-data:i386 \
		libasound2-plugins:i386 \
		libcurl3:i386 \
		libgtk2.0-0:i386 \
		libopenal1:i386 \
		libglu1:i386 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# I _really_ wanted to automate the downloading with wget or cURL but
# because the login form uses CSRF protection and a few other things you'd
# probably need to have a somewhat proper browser to parse their webpage
# in order to automate logging in and getting the session cookie. However,
# if you're already logged in then you can get the install from the url:
#          https://www.gog.com/downlink/undertale/en3installer1
COPY gog_undertale.sh /gog_undertale.sh

# Create a user so we don't run as root.
RUN useradd -m -d /home/chara -s /bin/false -c "You are filled with DETERMINATION." chara && \
	mkdir -p /home/chara/.config/UNDERTALE_linux /opt/games && \
	chown chara:chara -R /home/chara /opt/games

# TODO: I probably should make a wrapper script that is setuid and does the
#       chown of /home/chara/.config/UNDERTALE_linux manually, because it turns
#       out that GameMaker silently doesn't create save files if it gets and
#       EPERM. Which is definitely not a good bug and took me a while to find.

# Install UNDERTALE.
# After spending far too long trying to figure out how to hack around a
# MojoSetup installer (which is thankfully free software), it turns out that
# someone already implemented gog-install which already can unpack the combined
# MojoSetup+makeself amalgamation and install the actual game. Kudos.
USER chara
RUN gog-install --install-dir=/opt/games /gog_undertale.sh

ENTRYPOINT ["/opt/games/Undertale/start.sh"]
CMD []
