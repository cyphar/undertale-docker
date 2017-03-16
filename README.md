## `undertale-docker` ##

A super hacky Dockerfile for running the really awesome game UNDERTALE inside a
Docker container. Since it's a proprietary piece of software I don't feel
comfortable running it on my host (and I really wish it was a [free
software][fs] game in the first place...).

To build this container you first need to download the GOG installer for
Undertale (`gog_undertale_X.Y.Z.sh`) and place it in the same directory as
`Dockerfile` with a filename of `gog_undertale.sh` and then run the following
command (this part is all done with free software):

```
% docker build -t cyphar/undertale .
```

In order to run this container use the following command. This assumes that
group `17` corresponds to the `audio` group on your host machine (the group
that owns `/dev/snd/*` devices). Also currently I haven't figured out how to
make `Xauthority` act properly, so I run `xhost +si:localuser:chara` to allow
the container to create windows.

```
% xhost +si:localuser:cyphar
localuser:cyphar being added to access control list
% docker run -itd --rm -u chara:17 \
             -v $HOME/.config/UNDERTALE_linux:/home/chara/.config/UNDERTALE_linux:rw \
             -v /tmp/.X11-unix:/tmp/.X11-unix \
             -e DISPLAY=unix$DISPLAY \
             --device /dev/snd:/dev/snd:rwm \
             --net none \
             cyphar/undertale
```

If your save files aren't being created, make sure that
`$HOME/.config/UNDERTALE_linux` has permissions such that Chara can write to
it. This should work as a dirty hack.

```
% mkdir -p -m 0777 $HOME/.config/UNDERTALE_linux
```

Have fun, and stay determined.

[fs]: https://www.gnu.org/philosophy/free-sw.en.html

### License ###

This project (not the actual game) is licensed under the MIT license.

```
undertale-docker: running UNDERTALE in a Docker container
Copyright (C) 2017 Aleksa Sarai

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
```
