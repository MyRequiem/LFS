#! /bin/bash

DEST_DIR="$1"
FILE_NAME="$2"
PACKAGES="/var/log/packages"

# для утилиты removepkg пишем полные пути ко всем файлам установленного пакета
# в /var/log/packages/${PRGNAME}-${VERSION}
cd "${DEST_DIR}" || exit 1
find . | cut -d . -f 2- | sort >> "${PACKAGES}/${FILE_NAME}"
# удалим пустые строки в файле
sed -i '/^$/d' "${PACKAGES}/${FILE_NAME}"
