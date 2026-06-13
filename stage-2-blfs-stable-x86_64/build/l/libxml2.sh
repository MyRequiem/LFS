#! /bin/bash

PRGNAME="libxml2"

### libxml2 (XML parser library)
# Библиотека для чтения и записи XML-файлов, которые широко используются для
# хранения настроек и обмена данными.

# Required:    no
# Recommended: icu          (для лучшей поддержки UNICODE)
# Optional:    doxygen
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Удалим ненужный вызов git в meson.build
sed -i "/'git'/,+3d" meson.build || exit 1

###
# БУДЕМ ОТУЧАТЬ ДУРАКА ТРЕБОВАТЬ doxygen, ЕСЛИ НУЖНА СБОРКА python-bindings
###
#
# Создаем временную папку с фейковым doxygen, который обманет и Meson, и
# python/generator.py и всегда будет возвращать 0
mkdir -p /tmp/fake-bin
cat << 'EOF' > /tmp/fake-bin/doxygen
#!/bin/sh
# Когда Meson или генератор вызывают doxygen, мы просто создаем структуру
# пустых XML-файлов, которую они так отчаянно ищут в каталоге сборки
XML_DIR="doc/xml"
mkdir -p "${XML_DIR}"
echo '<?xml version="1.0" encoding="UTF-8" standalone="no"?><doxygen></doxygen>' > "${XML_DIR}/index.xml"
exit 0
EOF
chmod +x "/tmp/fake-bin/doxygen"

# Добавляем нашу заглушку в начало PATH
export PATH="/tmp/fake-bin:${PATH}"

# Нейтрализуем фатальное падение в python/generator.py, если XML пустой
sed -i "s/raise Exception(f'Doxygen XML not found in {dstPref}')/print('LFS HACK: Bypassing doxygen check')/g" python/generator.py

# Из-за того что наш фейковый XML пустой, генератор выдаст предупреждение, но
# не упадет. Нам нужно лишь создать пустую директорию, которую os.listdir()
# прочитает без FileNotFoundError
mkdir -p build/python/doc/xml

ICU="disables"
command -v icu-config &>/dev/null && ICU="enabled"

cd build || exit 1

# Включает поддержку Readline при запуске xmlcatalog или xmllint в консоли
#    -D history=enabled
# python bindings устарели из-за недостатков конструкции API и будут удалены в
# libxml2-2.16, а так же их сборка в версии 2.15.2 требует жесткую зависимость
# doxygen (мы ее ПОБЕДИЛИ выше), но пакет virt-manager требует python-bindins
# (runtime), поэтому:
#    -D python=enabled
meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D history=enabled  \
    -D python=enabled   \
    -D docs=disabled    \
    -D icu="${ICU}" || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды
rm -rf "${TMP_DIR}/usr/bin/__pycache__"
rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

# пакеты, которые зависят он libxml2 будут связываться только с общими
# библиотеками, а не со статическими
sed "s/--static/--shared/" -i "${TMP_DIR}/usr/bin/xml2-config"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML parser library)
#
# Libxml2 is the XML C parser library and toolkit. XML itself is a metalanguage
# to design markup languages -- i.e. a text language where structures are added
# to the content using extra "markup" information enclosed between angle
# brackets. HTML is the most well-known markup language. Though the library is
# written in C, a variety of language bindings make it available in other
# environments.
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}/-/wikis/home
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
