#! /bin/bash

if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

SLACK64_CURRENT="https://mirrors.slackware.com/slackware/slackware64-current"

###
# From: "${SLACK64_CURRENT}/source/x/noto-fonts-ttf/package-source.sh"
###

### смотрим последнюю версию пакета noto-fonts:
# https://github.com/notofonts/noto-fonts/releases
#    На 08.02.24: Noto fonts v20201206-phase3 as of 2020.12.06
VERSION="20201206-phase3"

GITREPO="https://github.com/googlefonts/noto-fonts"
if ! [ -r "./v${VERSION}.tar.gz" ]; then
    wget "${GITREPO}/archive/v${VERSION}.tar.gz" || {
        echo "Error download v${VERSION}.tar.gz !!!"
        exit 1
    }
fi

if ! [ -r ./fonts-to-skip.txt ]; then
    wget "${SLACK64_CURRENT}/source/x/noto-fonts-ttf/fonts-to-skip.txt" || {
        echo "Error download fonts-to-skip.txt !!!"
        exit 1
    }
fi

tar xvf "v${VERSION}.tar.gz" || exit 1

TARBALL_NAME="noto-fonts-ttf-$(echo "${VERSION}" | cut -d - -f 1)"
mkdir -p "${TARBALL_NAME}"/{hinted,unhinted}

find "noto-fonts-${VERSION}/hinted" -type f -name "*.ttf" -exec \
    cp {} "${TARBALL_NAME}/hinted" \;

find "noto-fonts-${VERSION}/unhinted" -type f -name "*.ttf" -exec \
    cp {} "${TARBALL_NAME}/unhinted" \;

# удалим шрифты, перечисленные в fonts-to-skip.txt (комментарии внутри)
cat fonts-to-skip.txt | while read LINE ; do
    if [ ! "$(echo "${LINE}" | cut -b 1)" = "#" ]; then
        RMFONT="$(echo "${LINE}" | tr -d " ")"
        rm -fv "${TARBALL_NAME}"/*hinted/NotoSans${RMFONT}-*.*
        rm -fv "${TARBALL_NAME}"/*hinted/NotoSerif${RMFONT}-*.*
    fi
done

# удалим шрифты пользовательского интерфейса (UI)
rm -fv "${TARBALL_NAME}"/*hinted/Noto{Sans,Serif}*UI-*.ttf

# удалим unhinted версии, если их hinted версии существуют
for HINTEDFONT in "${TARBALL_NAME}"/hinted/* ; do
    rm -fv "${TARBALL_NAME}"/unhinted/$(basename "${HINTEDFONT}")
done

mv "${TARBALL_NAME}"/*hinted/* "${TARBALL_NAME}"/
rm -rf "${TARBALL_NAME}"/{hinted,unhinted}

# удалим НЕ Noto шрифты (обычно это ChromeOS шрифты)
find "${TARBALL_NAME}" -type f ! -name "Noto*" -delete

# удалим редко используемые начертания
rm -fv "${TARBALL_NAME}"/*{Condensed,SemiBold,Extra}*.ttf

chown root:root "${TARBALL_NAME}"/*
chmod 644       "${TARBALL_NAME}"/*

# создаем архив
tar -cJvf "${TARBALL_NAME}.tar.xz" "${TARBALL_NAME}" || exit 1

# очищаем
rm -rf "v${VERSION}.tar.gz" fonts-to-skip.txt \
    "noto-fonts-${VERSION}" "${TARBALL_NAME}"
