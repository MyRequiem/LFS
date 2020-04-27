#! /bin/bash

PRGNAME="enchant"

### enchant (a wrapper for spellcheck libraries)
# Предоставляет универсальный интерфейс для различных библиотек проверки
# орфографии, таких как Aspell, Pspell, Ispell и т.д.

# http://www.linuxfromscratch.org/blfs/view/stable/general/enchant.html

# Home page: http://www.abisource.com/projects/enchant/
# Download:  https://github.com/AbiWord/enchant/releases/download/v2.2.7/enchant-2.2.7.tar.gz

# Required:    glib
# Recommended: aspell
#              aspell-dict-en
#              aspell-dict-ru
# Optional:    dbus-glib
#              hspell       (http://hspell.ivrix.org.il/)
#              hunspell     (http://hunspell.github.io/)
#              voikko       (https://voikko.puimula.org/)
#              unittest-cpp (для тестов) https://github.com/unittest-cpp/unittest-cpp/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если для тестов установлен пакет unittest-cpp
UNITTEST_CPP="--disable-relocatable"
[ -f /usr/lib/libUnitTest++.a ] && UNITTEST_CPP="--enable-relocatable"

./configure           \
    --prefix=/usr     \
    "${UNITTEST_CPP}" \
    --disable-static || exit 1

make || exit 1
# make check

make install
make install DESTDIR="${TMP_DIR}"

# удаляем директорию /usr/include/enchant, остается только
# /usr/include/enchant-2
INCLUDE_ENCHANT="/usr/include/enchant"
rm -rf "${INCLUDE_ENCHANT}"
rm -rf "${TMP_DIR}${INCLUDE_ENCHANT}"

# создаем символические ссылки для того, чтобы другие пакеты могли найти его,
# используя старое имя
# в /usr/include        enchant       -> enchant-2
# в /usr/bin/           enchant       -> enchant-2
# в /usr/lib/           libenchant.so -> libenchant-2.so
# в /usr/lib/pkgconfig  enchant.pc    -> enchant-2.pc
ln -sfv enchant-2       "${INCLUDE_ENCHANT}"
ln -sfv enchant-2       /usr/bin/enchant
ln -sfv libenchant-2.so /usr/lib/libenchant.so
ln -sfv enchant-2.pc    /usr/lib/pkgconfig/enchant.pc
(
    cd "${TMP_DIR}/usr/include" || exit 1
    ln -sfv enchant-2 enchant
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv enchant-2 enchant
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv libenchant-2.so libenchant.so
    cd "${TMP_DIR}/usr/lib/pkgconfig" || exit 1
    ln -sfv enchant-2.pc enchant.pc
)

### Проверка установки
# создадим файл /tmp/test-enchant.txt
# cat > /tmp/test-enchant.txt << "EOF"
# Tel me more abot linux
# Ther ar so many commads
# EOF
#
# вывод списка слов с ошибками
# enchant -d en_US -l /tmp/test-enchant.txt
# вывод списка альтернатив для ошибочных слов
# enchant -d en_US -a /tmp/test-enchant.txt

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a wrapper for spellcheck libraries)
#
# The enchant package provide a generic interface into various existing spell
# checking libraries. Enchant supports:
#    * Aspell/Pspell
#    * Ispell
#    * MySpell/HunSpell
#    * Uspell (Yiddish, Hebrew and Eastern European languages)
#    * Hspell (Hebrew) and others
#
# Home page: http://www.abisource.com/projects/${PRGNAME}/
# Download:  https://github.com/AbiWord/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
