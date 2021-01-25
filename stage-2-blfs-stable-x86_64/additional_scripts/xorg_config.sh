#! /bin/bash

# shellcheck disable=SC2034
XORG_PREFIX=/usr
XORG_CONFIG="--prefix=${XORG_PREFIX} \
             --sysconfdir=/etc       \
             --localstatedir=/var    \
             --disable-static        \
"
