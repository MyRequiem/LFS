#!/bin/sh

SCRIPT_NAME="$(basename "$0")"
MODULE="$1"

if [ "$(id -u)" = "0" ]; then
    echo "${SCRIPT_NAME} should be run as a normal user (not root)"
    exit 1
fi

# check npm command
if ! command -v npm 1>/dev/null; then
    echo "npm: command not found"
    echo "You need to install nodejs package"
    exit 1
fi

# check param (node module name)
# shellcheck disable=SC3010
if [[ -z "${MODULE}" || "${MODULE}" = "--help" || "${MODULE}" = "-h" ]]; then
    echo "Usage: ./${SCRIPT_NAME} <module_name>"
    echo "Example:"
    echo "  ./${SCRIPT_NAME} jslint"
    echo "  ./${SCRIPT_NAME} instant-markdown-d"
    exit 0
fi

VERSION="$(npm view "${MODULE}" 2>/dev/null | grep latest | cut -d " " -f 2)"

if [ -z "${VERSION}" ]; then
    echo "Version for ${MODULE} module not found"
    echo "Try:"
    echo "    $ npm search <module_name>"
    echo "    $ npm view   <module_name>"
    exit 1
fi

TMP_DIR="/tmp/build-${MODULE}_npm-${VERSION}"
sudo rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}" || exit 1

DESTDIR="${TMP_DIR}" npm install -g "${MODULE}" || exit 1

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"
rm -rf "${TMP_DIR}/usr/share/help"
rm -rf "${TMP_DIR}/usr/share/info"

sudo chown -R root:root .
sudo find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

sudo /bin/cp -vpR "${TMP_DIR}"/* /

JSON="usr/lib/node_modules/${MODULE}/package.json"
DESCRIPTION="$(grep -i "\"description\":" "${JSON}" | cut -d \" -f 4)"
HOMEPAGE="$(grep -i "\"homepage\":" "${JSON}" | cut -d \" -f 4)"
DOWNLOAD="$(npm view "${MODULE}" | grep ".tarball:" | cut -d " " -f 2)"

VLP="/var/log/packages/${MODULE}_npm-${VERSION}"
sudo rm -f "${VLP}"
echo "# Package: ${MODULE}_npm" | sudo tee -a "${VLP}" 1>/dev/null
echo "#"                        | sudo tee -a "${VLP}" 1>/dev/null
echo "# ${DESCRIPTION}"         | sudo tee -a "${VLP}" 1>/dev/null
echo "#"                        | sudo tee -a "${VLP}" 1>/dev/null
echo "# Home page: ${HOMEPAGE}" | sudo tee -a "${VLP}" 1>/dev/null
echo "# Download:  ${DOWNLOAD}" | sudo tee -a "${VLP}" 1>/dev/null
echo "#"                        | sudo tee -a "${VLP}" 1>/dev/null

find . | cut -d . -f 2- | sort | sudo tee -a "${VLP}" 1>/dev/null
# удалим пустые строки
sudo sed -i '/^$/d' "${VLP}"
