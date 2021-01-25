#! /bin/bash

XORG_PREFIX=/usr
XORG_CONFIG="                 \
    --prefix"=${XORG_PREFIX}" \
    --sysconfdir=/etc         \
    --localstatedir=/var      \
    --disable-static          \
"
export XORG_PREFIX XORG_CONFIG
