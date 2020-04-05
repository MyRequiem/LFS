#! /bin/bash


### Шрифты для терминала linux
# Пакет описан в BLFS, но установим его сейчас для настройки нормального
# шрифта для чистой консоли в файле /etc/sysconfig/console
#
# Home page: http://terminus-font.sourceforge.net

PRGNAME="terminus-font"
VERSION="4.48"

# Шрифты устанавливаются в /usr/share/consolefonts


echo -ne "\\nAre you sure you are logged in chroot ??? [y/N]: "
read -r JUNK
[[ "x${JUNK}" != "xy" && "x${JUNK}" != "xY" ]] && exit 0


mkdir -p /build
cd /build || exit 1
rm -rf "${PRGNAME}-${VERSION}"

tar xvf "/sources/${PRGNAME}-${VERSION}".tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

./configure \
    --prefix=/usr

# собираем только PSF шрифты для чистого терминала. В пакете присутствуют еще
# PCF шрифты для X Window System, но для их сборки нужна утилита bdftopcf
# входящая в состав иксов, которые пока не установлены
make psf

# устанавливаем во временную директорию, записываем полные пути ко всем файлам
# пакета в /var/log/packages/${PRGNAME}-${VERSION}
PKG="/tmp/package-${PRGNAME}-${VERSION}"
rm -rf "${PKG}"
mkdir -p "${PKG}"
make install-psf DESTDIR="${PKG}"
(
    cd "${PKG}" || exit 1
    find . | cut -d . -f 2- > /var/log/packages/${PRGNAME}-${VERSION}
    # удалим первую пустую строку в файле
    sed -i '1d' /var/log/packages/${PRGNAME}-${VERSION}
)

# устанавливаем пакет в систему
make install-psf
