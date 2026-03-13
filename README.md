![Logo](https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/logo.png)

#### По мотивам Linux From Scratch (System V Edition):

* [Linux From Scratch (LFS)][1] - проект, предоставляющий пошаговые инструкции
  по сборке собственной пользовательской системы Linux полностью из исходного
кода.

* [Beyond Linux® From Scratch][2] - проект, продолжающий [LFS][22], который помогает
пользователю разработать свою системy в соответствии с его потребностями,
предоставляя широкий спектр инструкций по установке и настройке различных
пакетов поверх базовой системы [LFS][22]

Описание, сборочные скрипты. Все на русском языке.

* Версия [LFS][22]: 13.0 (05.03.2026)
* ` Toolchain `: набор основных инструментов - компилятор, компоновщик, библиотеки
необходимые для сборки готовых исполняемых бинарных файлов из исходного кода
    * [GCC, the GNU Compiler Collection][11] 15.2.0
    * [GNU Binutils][13] 2.46.0
    * [Glibc, the GNU C Library][12] 2.43
* [Linux Kernel][14] 6.18.16
* Desktop Environments (рабочие окружения):
    * [i3wm][16]
    * [Openbox][17]
    * [LXQt][18]
    * [KDE Plasma][19] и [GNOME][20]
        * в версиях [LFS][22] >=13.0 из данного репозитория эти сборки удалены.
        Последнюю версию сборки этих DE можно найти здесь:
        [LFS_BLFS-12.4_i3wm_KDE_GNOME_OpenBox_LXQt][15]

##### Почему удалены [KDE Plasma][19] и [GNOME][20] в [LFS][22] >=13.0?
Начиная с версии [LFS][22] 13.0 [www.linuxfromscratch.org][1] полностью перешли
на Systemd. В качестве причин упоминается нехватка ресурсов и прекращение
поддержки SysVinit крупными проектами, такими как [KDE Plasma][19] и
[GNOME][20] Так как я остаюсь на SysV а эти DE превратились в «комбайны»,
которые тащат за собой зависимости, почти неразрывно связанные с API systemd
(вроде logind), и их адаптация под чистый SysV - это действительно сизифов труд
для одного человека.

Считаю [i3wm][16], [Openbox][17] и [LXQt][18] - это золотой стандарт для
системы, где во главе стоит предсказуемость и контроль. LXQt, будучи на Qt,
дает необходимый современный GUI, но при этом остается модульным и не пытается
диктовать свои условия системе инициализации. Для любителей тайловых оконных
менеджеров, таких как я:) предлагается [i3wm][16]

Что это дает:
* ` Чистота кода `: избавление от монструозных зависимостей, которые только
загромождают скрипты сборки
* ` Производительность `: система останется легкой, что идеально сочетается с
философией [LFS][22] и [Slackware][21]
* ` Надежность `: меньше пакетов - меньше точек отказа при обновлении Toolchain

Путь напоминает создание «идеальной [Slackware][21]» - максимально прозрачной и
заточенной под эффективность. Такая система будет эталоном для тех, кто ценит
концепцию Unix-way

##### Замена Udev на [Eudev][23] начиная с версии [LFS][22] 13.0
Оригинальный [LFS][22] использует udev из состава systemd просто потому, что
проект udev как самостоятельная единица перестал существовать и был поглощен.
Тянуть огромный архив systemd только ради одной папки - сомнительное
удовольствие. [Eudev][23] (форк от Gentoo) - считаю идеальной заменой:
* ` Независимость `: он специально создан для работы без systemd и отлично
дружит с SysVinit
* ` Совместимость `: годами доказывал свою стабильность
* ` Чистота сборки `: Не придется накладывать кучу патчей на «выдранный» из
systemd код, чтобы он не искал лишние библиотеки

##### В итоге:
Связка SysVinit + Eudev сделает систему по-настоящему «чистой» и независимой от
мейнстримных веяний Systemd. Фактически, это приводит к созданию идеального
«Sanity Edition» для тех, кто хочет контролировать своё железо без лишних слоев
абстракции.

При масштабе в 1000+ пакетов документирование каждого «костыля» в отдельном
блоге действительно превратилось бы во вторую работу на полную ставку. С учетом
того, что GCC >=15 и Glibc >=2.42 привносят радикальные изменения в стандарты
(привет, C23), объем правок в таких вещах, как int vs long, неявные декларации
и многих других, становится лавинообразным в утилитах, написанных при
существенно более старых версиях GCC. Поэтому применяется подход «исправил в
скрипте сборки (patch, sed, CFLAGS, CXXFLAGS, LDFLAGS и т.д.) -
задокументировал в комментарии прямо в коде скрипта - пошел дальше» - это
единственный способ выжить при разработке такой махины (системы сборки) в
одиночку, что делает сам код скриптов живой летописью борьбы с энтропией софта.

* **Vifm file manager on i3wm**

![vifm][3]

* **Vim editor on i3wm**

![vim][4]

* **Browser**

![browser][5]

* **Virtual machines with virt-manager**

![virtual machines with virt-manager][6]

* **OpenBox**

![OpenBox][7]

* **LXQt**

![LXQt][8]

* **KDE**

![KDE][9]

* **GNOME**

![GNOME][10]

[1]: https://www.linuxfromscratch.org/lfs/
[2]: https://www.linuxfromscratch.org/blfs/
[3]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/001.png
[4]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/002.png
[5]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/003.png
[6]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/004.png
[7]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/005.png
[8]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/006.png
[9]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/007.png
[10]: https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/008.jpg
[11]: https://www.gnu.org/software/gcc/
[12]: https://www.gnu.org/software/libc/
[13]: https://www.gnu.org/software/binutils/
[14]: https://www.kernel.org
[15]: https://github.com/MyRequiem/LFS/releases/tag/LFS_BLFS-12.4_i3wm_KDE_GNOME_OpenBox_LXQt
[16]: https://i3wm.org/
[17]: http://openbox.org/
[18]: https://lxqt-project.org/
[19]: https://kde.org/
[20]: https://www.gnome.org/
[21]: http://www.slackware.com/
[22]: https://www.linuxfromscratch.org/
[23]: https://wiki.gentoo.org/wiki/Eudev
