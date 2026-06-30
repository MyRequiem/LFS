#!/bin/bash

# /usr/sbin/remove-la-files.sh
# Written for Beyond Linux From Scratch
# by Bruce Dubbs <bdubbs@linuxfromscratch.org>
# Edited by MyRequiem <mrvladislavovich@gmail.com>
#
# Identifies and move libtool archive files (.la) in the
# /var/log/removed_la_files/ directory. In modern Linux distributions, these
# files are often redundant and can cause issues during linking or system
# updates.
#

# make sure we are running with root privileges
if test "${EUID}" -ne 0; then
    echo "Error: $(basename ${0}) must be run as the root user! Exiting..."
    exit 1
fi

# make sure PKG_CONFIG_PATH is set if discarded by sudo
[ -r /etc/profile ] && source /etc/profile

OLD_LA_DIR=/var/log/removed_la_files

mkdir -p $OLD_LA_DIR

# only search directories in /opt, but not symlinks to directories
OPTDIRS=$(find /opt -mindepth 1 -maxdepth 1 -type d)

# move any found .la files to a directory out of the way
find /usr/lib /usr/libexec $OPTDIRS -name "*.la" \
    ! -path "/usr/lib/ImageMagick*" -exec mv -fv {} $OLD_LA_DIR \;

###############

# fix any .pc files that may have .la references

STD_PC_PATH='/usr/lib/pkgconfig
             /usr/share/pkgconfig
             /usr/local/lib/pkgconfig
             /usr/local/share/pkgconfig'

# for each directory that can have .pc files
for d in $(echo $PKG_CONFIG_PATH | tr : ' ') $STD_PC_PATH; do
  # for each pc file
  for pc in $d/*.pc ; do
    if [ $pc == "$d/*.pc" ]; then continue; fi

    # check each word in a line with a .la reference
    for word in $(grep '\.la' $pc); do
      if $(echo $word | grep -q '.la$' ); then
        mkdir -p $d/la-backup
        cp -fv  $pc $d/la-backup

        basename=$(basename $word )
        libref=$(echo $basename|sed -e 's/^lib/-l/' -e 's/\.la$//')

        # fix the .pc file
        sed -i "s:$word:$libref:" $pc
      fi
    done
  done
done
