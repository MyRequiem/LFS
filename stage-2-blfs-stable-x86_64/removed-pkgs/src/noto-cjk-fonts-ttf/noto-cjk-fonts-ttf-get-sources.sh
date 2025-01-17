#! /bin/bash

if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

SLACK64_CURRENT="https://mirrors.slackware.com/slackware/slackware64-current"

###
# From: "${SLACK64_CURRENT}/source/x/noto-cjk-fonts-ttf/package-source.sh"
###

### смотрим последнюю версию пакета noto-cjk-fonts
# https://github.com/notofonts/noto-cjk/releases
#    На 09.02.24: Noto CJK v20201206 as of 2020.12.06
VERSION="20201206"

GITREPO="https://github.com/googlefonts/noto-cjk"
if ! [ -r "./v${VERSION}-cjk.tar.gz" ]; then
    wget "${GITREPO}/archive/v${VERSION}-cjk.tar.gz" || {
        echo "Error download v${VERSION}-cjk.tar.gz !!!"
        exit 1
    }
fi

tar xvf "v${VERSION}-cjk.tar.gz" || exit 1

TARBALL_NAME="noto-cjk-fonts-ttf-${VERSION}"
mkdir -p "${TARBALL_NAME}"

(
    cd "noto-cjk-${VERSION}-cjk" || exit
    unzip NotoSansCJK.ttc.zip
)

cp "noto-cjk-${VERSION}-cjk"/{NotoSansCJK.ttc,NotoSerifCJK-Regular.ttc} \
    "${TARBALL_NAME}"

chown root:root "${TARBALL_NAME}"/*
chmod 644       "${TARBALL_NAME}"/*

# создаем архив
tar -cJvf "${TARBALL_NAME}.tar.xz" "${TARBALL_NAME}" || exit 1

# очищаем
rm -rf "v${VERSION}-cjk.tar.gz" "noto-cjk-${VERSION}-cjk" "${TARBALL_NAME}"
