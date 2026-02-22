![Logo](https://raw.githubusercontent.com/MyRequiem/LFS/master/stage-2-blfs-stable-x86_64/imgs/logo.png)

#### По мотивам Linux From Scratch (System V Edition):

* [Linux From Scratch][1] - проект, предоставляющий пошаговые инструкции по
сборке собственной пользовательской системы Linux полностью из исходного кода.

* [Beyond Linux® From Scratch][2] - проект, продолжающий LFS, который помогает
пользователю разработать свою системy в соответствии с его потребностями,
предоставляя широкий спектр инструкций по установке и настройке различных
пакетов поверх базовой системы LFS.

* Версия: 12.4 (01.09.2025)
* Toolchain: набор основных инструментов - компилятор, компоновщик, библиотеки
необходимые для сборки готовых исполняемых бинарных файлов из исходного кода
    * [GCC, the GNU Compiler Collection][11] 15.2.0
    * [GNU Binutils][13] 2.45
    * [Glibc, the GNU C Library][12] 2.42
* [Linux Kernel][14] 6.16.3
* Desktop Environments (рабочие окружения):
    * [i3wm][16]
    * [Openbox][17]
    * [LXQt][18]
    * [KDE][19] и [GNOME][20]
        * в версиях LFS >12.4 из данного репозитория эти сборки удалены.
        Последнюю версию сборки этих DE можно найти здесь:
        [LFS_BLFS-12.4_i3wm_KDE_GNOME_OpenBox_LXQt][15]

Описание, сборочные скрипты. Все на русском языке.

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
