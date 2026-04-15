#! /bin/bash

PRGNAME="docbook-xsl"
ARCH_NAME="${PRGNAME}-nons"

### docbook-xsl (Stylesheets package)
# Набор готовых стилей и правил, которые превращают скучный код DocBook в
# готовые красивые файлы: PDF, HTML или man-страницы. Если сам DocBook - это
# только текст и структура, то этот пакет отвечает за то, как именно этот текст
# будет выглядеть в итоге (шрифты, отступы, таблицы).

# Required:    libxml2
#              docbook-xml
# Recommended: no
# Optional:    apache-ant       (для сборки "webhelp" документации)
#              libxslt
#              ruby             (для использования таблиц стилей "epub")
#              zip              (для сборки "epub3" документации)
#              saxon6           (используется вместе с apache-ant) https://sourceforge.net/projects/saxon/files/saxon6/
#              xerces2-java     (используется вместе с apache-ant) http://xerces.apache.org/xerces2-j/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
XSL_STYLESHEETS="/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"
mkdir -pv "${TMP_DIR}${XSL_STYLESHEETS}"

# исправим проблему переполнения стека при выполнении рекурсии
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-stack_fix-1.patch" || exit 1

cp -vR VERSION assembly common eclipse epub epub3 extensions fo        \
       highlighting html htmlhelp images javahelp lib manpages params  \
       profiling roundtrip slides template tests tools webhelp website \
       xhtml xhtml-1_1 xhtml5                                          \
       "${TMP_DIR}${XSL_STYLESHEETS}" || exit 1

ln -svf VERSION "${TMP_DIR}${XSL_STYLESHEETS}/VERSION.xsl"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# /etc/xml/catalog установлен с пакетом docbook-xml, поэтому его включил в
# Required зависимость. Дополним его:
for URI in http{,s}://cdn.docbook.org/release/xsl-nons/{${VERSION},current} \
        http://docbook.sourceforge.net/release/xsl/current; do
    for REWRITE in System URI; do
        xmlcatalog --noout --add "rewrite${REWRITE}" \
        "${URI}"                                     \
        "${XSL_STYLESHEETS}"                         \
        /etc/xml/catalog
    done
done

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Stylesheets package)
#
# The DocBook XSL Stylesheets package contains XSL stylesheets. These are
# useful for performing transformations on XML DocBook files.
#
# Home page: https://github.com/docbook/xslt10-stylesheets/
# Download:  https://github.com/docbook/xslt10-stylesheets/releases/download/release/${VERSION}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
