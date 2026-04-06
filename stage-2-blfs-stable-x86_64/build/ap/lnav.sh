#! /bin/bash

PRGNAME="lnav"

### lnav (The Log File Navigator)
# Продвинутый просмотрщик системных журналов (логов), который автоматически
# подсвечивает важное и объединяет сообщения из разных файлов.

# Required:    rustc
# Recommended: no
# Optional:    curl
#              libarchive

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# NOTE
# Во время сборки скачиваются Rust зависимости. Подготовим их сразу во
# избежании Download ERROR во время сборки.
###

cd src/third-party/prqlc-c/ || exit 1
# скачает и распакует все зависимости в директорию vendor
cargo vendor || exit 1

# настройка cargo для использования локальных (vendored) зависимостей без сети
# (мы уже их скачали и распаковали)
mkdir -pv .cargo
cat << EOF > .cargo/config.toml
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"
EOF

cd - || exit 1

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# очистим rust кэш, мусор не нужен
rm -rf /root/.cargo

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Log File Navigator)
#
# An enhanced log file viewer that takes advantage of any semantic information
# that can be gleaned from the files being viewed, such as timestamps and log
# levels. Using this extra semantic information, lnav can do things like
# interleaving messages from different files, generate histograms of messages
# over time, and providing hotkeys for navigating through the file. It is hoped
# that these features will allow the user to quickly and efficiently zero in on
# problems.
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/tstack/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
