#! /usr/bin/env python3
# -*- coding: utf-8 -*-

"""
checking LFS and BLFS update
"""

import re
import urllib.request
from glob import glob as Glob

from bs4 import BeautifulSoup


def fix_pkg_name(name):
    """
    fix package name
    """
    if name == 'kdenlive-19':
        name = 'kdenlive'

    if name == 'python':
        name = 'python3'

    if name == 'webkitgtk':
        name = 'webkitgtk+2'

    if name == 'apache':
        name = 'httpd'

    if name == 'libjpeg':
        name = 'libjpeg-turbo'

    if name == 'x7lib':
        name = 'xorg-libraries'

    if name == 'mitkrb':
        name = 'mit-kerberos-v5'

    if name == 'libexif-0':
        name = 'libexif'

    if name == 'libxml2-2':
        name = 'libxml2'

    if name == 'glib2':
        name = 'glib'

    if name == 'freetype2':
        name = 'freetype'

    return name


def main(repo, repo_version):
    """
    main
    """

    book_url = 'http://www.linuxfromscratch.org'
    errata_url = '{0}/{1}/errata/{2}/'.format(book_url, repo, repo_version)
    print('### {0}'.format(errata_url))

    response = urllib.request.urlopen(errata_url)
    soup = BeautifulSoup(response,
                         from_encoding=response.info().get_param('charset'),
                         features='html.parser')

    max_len = 0
    pkg_list = []
    for link in soup.find_all('a', href=True):
        href = link['href']

        # выбираем только нужные нам ссылки
        true_link = (href.endswith('.html') and
                     ('/development/' in href or '/svn/' in href))

        if not true_link:
            true_link = href.endswith('.patch')

        if true_link:
            # получаем имя пакета из ссылки, например:
            # ../../view/development/chapter08/openssl.html --> openssl
            # переводим в нижний регистр и исправляем его в соответствии с
            # именованием пакетов в системе
            pkg_name = fix_pkg_name(href.split('/')[-1].split('.')[0].lower())

            pkg_name_len = len(pkg_name)
            max_len = max_len if pkg_name_len < max_len else pkg_name_len

            # создаем ссылку с абсолютным путем к странице пакета
            if not href.endswith('.patch'):
                href = '{0}/{1}/{2}'.format(book_url,
                                            repo,
                                            '/'.join(href.split('/')[2:]))

            pkg_list.append({'pkg_name': pkg_name, 'href': href})

    # сортируем массив объектов по имени пакета
    pkg_list = sorted(pkg_list, key=lambda obj: obj['pkg_name'])

    clrs = {
        'yellow': '\x1b[0;33m',
        'lred': '\x1b[1;31m',
        'lblue': '\x1b[1;34m',
        'grey': '\x1b[38;5;247m',
        'reset': '\x1b[0m'
    }

    for pkg in pkg_list:
        find_pkg = Glob(('/mnt/lfs/var/log/packages/'
                         '{0}-[0-9]*').format(pkg['pkg_name']))
        pkg_exist = len(find_pkg) > 0

        new_version = ''
        system_version = ''
        color = clrs['grey']
        update = ''
        if pkg_exist:
            color = clrs['yellow']
            system_version = find_pkg[0].split('-')[-1].strip()
            try:
                resp = urllib.request.urlopen(pkg['href'])
            except urllib.error.HTTPError:
                continue

            soup = BeautifulSoup(resp,
                                 from_encoding=resp.info().get_param('charset'),
                                 features='html.parser')
            if pkg['pkg_name'] == 'xorg-libraries':
                # версия пакета xorg-libraries == версии библиотеки libX11,
                # поэтому ищем на странице тег <code> и в нем libX11-x.x.x.tar.
                code_content = soup.findAll('code')[0].contents[0]
                pattern = r'libX11-([^\s]+)\.tar'
                result = re.search(pattern, code_content)
                new_version = result.group(1)
            else:
                new_version = soup.find_all('h1')
                if not new_version:
                    new_version = ''
                else:
                    new_version = new_version[0].contents[2]
                    new_version = new_version.split('-')[-1].strip()

            update = '{0}[{1}] '.format(clrs['reset'], system_version)
            if new_version and system_version != new_version:
                update = '{0}{1} --> {2}{3} '.format(clrs['lred'],
                                                     system_version,
                                                     new_version,
                                                     clrs['reset'])
                color = clrs['lred']

        print(('{0}{1}{2}{3}{4}'
               '{5}{6}').format(color,
                                pkg['pkg_name'],
                                ' ' * (max_len - len(pkg['pkg_name']) + 7),
                                update,
                                clrs['lblue'],
                                pkg['href'],
                                clrs['reset']))


main('lfs', '10.0')
main('blfs', '10.0')
