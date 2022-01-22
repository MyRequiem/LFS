#! /bin/bash

PRGNAME="enchant"

### enchant (a wrapper for spellcheck libraries)
# Общий интерфейс для различных библиотек проверки орфографии (Aspell/Pspell,
# Ispell и др.)

# Required:    glib
# Recommended: aspell
# Optional:    dbus-glib
#              doxygen
#              hspell       (http://hspell.ivrix.org.il/)
#              hunspell     (http://hunspell.github.io/)
#              nuspell      (https://nuspell.github.io/)
#              voikko       (https://voikko.puimula.org/)
#              unittest-cpp (требуется для тестов) https://github.com/unittest-cpp/unittest-cpp/releases

# NOTE:
# после установки пакета можно проверить его работу создав файл:
#    cat << EOF > /tmp/test-enchant.txt
#    Tel me more abot linux
#    Ther ar so many commads
#    EOF
#
# вывод всех слов с ошибками
#    # enchant -d en_GB -l /tmp/test-enchant.txt
# вывод всех альтернатив для слов с ошибками
#    # enchant -d en_GB -a /tmp/test-enchant.txt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1

# для запуска тестов должна быть установлена опциональная зависимость
# unittest-cpp, а так же небходимо в параметры конфигурации добавить опцию
#    --enable-relocatable
# make check

make install DESTDIR="${TMP_DIR}"

# создадим ссылки, чтобы другие программы могли найти enchant по старому имени
ln -sfv enchant-2       "${TMP_DIR}/usr/bin/enchant"
ln -sfv enchant-2       "${TMP_DIR}/usr/include/enchant"
ln -sfv libenchant-2.so "${TMP_DIR}/usr/lib/libenchant.so"
ln -sfv enchant-2.pc    "${TMP_DIR}/usr/lib/pkgconfig/enchant.pc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a wrapper for spellcheck libraries)
#
# The enchant package provide a generic interface into various existing spell
# checking libraries
#
# Enchant supports:
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
