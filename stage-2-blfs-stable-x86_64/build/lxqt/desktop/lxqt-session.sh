#! /bin/bash

PRGNAME="lxqt-session"

### lxqt-session (default session manager for LXQt)
# Менеджер сеансов (session manager) для LXQt по умолчанию

# Required:    liblxqt
#              qtxdg-tools
#              xdg-user-dirs
# Recommended: no
# Optional:    no

### NOTE:
# Запуск сессии LXQt командой startx (с runlevel 3)
#    в ~/.xinitrc добавляем
#    ----------------------
#    exec startlxqt
#
# При первом запуске LXQt запросит оконный менеджер. Используем Openbox. В этот
# момент фон и панель будут черными. ПКМ по фону -> меню -> выбераем "Настройки
# рабочего стола" чтобы изменить цвет фона или установить фоновое изображение.

# Панель будет находиться внизу экрана. ПКМ по панели -> Меню настроить панель.
# Настраиваем добавление виджетов и цвет фона. Рекомендуется установка, как
# минимум, виджетов «Диспетчер приложений» и «Диспетчер задач».

# Файлы конфигурации будут созданы в каталоге
#    ~/.config/lxqt/
# чтобы значки виджетов отображались правильно, файл lxqt.conf возможно
# придется отредактировать, включив в него строку
#    icon_theme=oxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# если используется DM (display manager: sddm, gdm, lightdm и т.д.), необходимо
# указать полный путь в параметре TryExec файла lxqt.desktop, чтобы рабочий
# стол LXQt появился в списке сеансов
sed -e '/TryExec/s|=|=/usr/bin/|' -i xsession/lxqt.desktop.in || exit 1

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (default session manager for LXQt)
#
# The lxqt-session package contains the default session manager for LXQt
#
# Home page: https://github.com/lxqt/${PRGNAME}/
# Download:  https://github.com/lxqt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
