#! /usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Checking  BLFS updates

NOTE:
see __LFS_VERSION and __PACKAGES_PATH variables
"""

import re
import urllib.request
from glob import glob as Glob

from bs4 import BeautifulSoup


__LFS_VERSION = '10.0'
__PACKAGES_PATH = '/mnt/lfs/var/log/packages'


def fix_pkg_name(name):
    """
    fix package name
    """

    pkgs = {
        # 'имя_пакета_в_системе': 'имя_пакета_в_ссылке_на_него'
        'cifs-utils': 'cifsutils',
        'freetype': 'freetype2',
        'glib': 'glib2',
        'gstreamer': 'gstreamer10',
        'jinja': 'Jinja2',
        'mit-kerberos-v5': 'mitkrb',
        'libx11': 'x7lib',
        'openjpeg': 'openjpeg2',
        'vorbis-tools': 'vorbistools'
    }

    tmp_name = name
    if pkgs.get(tmp_name):
        tmp_name = pkgs[tmp_name]

    return tmp_name


def main():
    """
    main
    """

    book_url = 'http://www.linuxfromscratch.org'
    advisories_url = '{0}/blfs/advisories'.format(book_url)
    errata_url = '{0}/{1}.html'.format(advisories_url, __LFS_VERSION)
    print('# Errata for BLFS {0}\n# {1}\n'.format(__LFS_VERSION, errata_url))

    response = urllib.request.urlopen(errata_url)
    soup = BeautifulSoup(response,
                         from_encoding=response.info().get_param('charset'),
                         features='html.parser')

    # со страницы Errata берем все названия обновленных пакетов (теги <h3>)
    # pkgs = [{'pkg_name': pkg_name, 'href': href}, ...]
    pkgs = []
    max_len = 0
    for pkg_name in soup.find_all('h3'):
        # >> type(pkg_name)
        # <class 'bs4.element.Tag'>
        # >> print(pkg_name)
        # <h3>BIND</h3>
        # type(pkg_name.contents)
        # <class 'list'>
        # >> print(pkg_name)
        # ['BIND']
        pkg_name = ' '.join(pkg_name.contents).lower()

        # intel microcode - это Firmware, пропускаем
        if pkg_name == 'intel microcode':
            continue

        # perl - это LFS, пропускаем
        if pkg_name == 'perl':
            continue

        if pkg_name == 'the gstreamer stack':
            pkg_name = pkg_name.split()[1]

        if pkg_name == 'vorbis tools':
            pkg_name = 'vorbis-tools'

        # js69, js78 и т.д. --> mozjs
        if re.search(r'^js\d+$', pkg_name):
            mozilla_js_engine = pkg_name
            pkg_name = 'mozjs'

        if pkg_name == 'kerberos':
            pkg_name = 'mit-kerberos-v5'

        if pkg_name == 'jinja2':
            pkg_name = 'jinja'

        if pkg_name == 'node.js':
            pkg_name = 'nodejs'

        if pkg_name == 'python':
            pkgs.append({'pkg_name': 'python2', 'href': ''})
            pkg_name = 'python3'

        if pkg_name == 'qt5 and qtwebengine':
            pkgs.append({'pkg_name': 'qt5', 'href': ''})
            pkg_name = 'qtwebengine'

        pkg_name_len = len(pkg_name)
        max_len = max_len if pkg_name_len < max_len else pkg_name_len
        pkgs.append({'pkg_name': pkg_name, 'href': ''})

    # сортируем массив объектов по имени пакета
    pkgs = sorted(pkgs, key=lambda obj: obj['pkg_name'])

    consolidated_url = '{0}/consolidated.html'.format(advisories_url)
    response = urllib.request.urlopen(consolidated_url)
    soup = BeautifulSoup(response,
                         from_encoding=response.info().get_param('charset'),
                         features='html.parser')

    for pkg in pkgs:
        for link in soup.find_all('a', href=True):
            if pkg['href']:
                continue

            inner_html = link.contents[0] if len(link.contents) > 0 else ''
            if not inner_html:
                continue

            true_link = '(sysv)' in inner_html
            if not true_link:
                continue

            href = link['href']
            true_link = '/development/' in href or '/svn/' in href
            if not true_link:
                continue

            _fix_pkg_name = fix_pkg_name(pkg['pkg_name'])

            # для пакета 'mozjs'
            if pkg['pkg_name'] == 'mozjs':
                _fix_pkg_name = mozilla_js_engine

            if (href.endswith('/{0}.html'.format(_fix_pkg_name)) or
                    href.endswith('#{0}'.format(_fix_pkg_name))):
                # создаем ссылку с абсолютным путем к странице пакета
                # ../../lfs/view/development/.. - ссылки на LFS пакеты
                # ../view/svn/..                - ссылки на BLFS пакеты
                if '/svn/' in href:
                    ind = 1
                    repo = 'blfs/'
                else:
                    ind = 3
                    repo = 'lfs/'
                href = '{0}/{1}{2}'.format(book_url,
                                           repo,
                                           '/'.join(href.split('/')[ind:]))
                pkg['href'] = href.split('#')[0]

        if not pkg['href']:
            pkg['href'] = '<no action is now necessary>'

    clrs = {
        'yellow': '\x1b[0;33m',
        'lred': '\x1b[1;31m',
        'lblue': '\x1b[1;34m',
        'grey': '\x1b[38;5;247m',
        'reset': '\x1b[0m'
    }

    for pkg in pkgs:
        find_pkg = Glob('{0}/{1}-[0-9]*'.format(__PACKAGES_PATH,
                                                pkg['pkg_name']))

        pkg_exist = len(find_pkg) > 0
        new_version = ''
        system_version = ''
        color = clrs['grey']
        update = ''
        if pkg_exist:
            color = clrs['yellow']
            system_version = find_pkg[0].split('-')[-1].strip()

            if '://' in pkg['href']:
                try:
                    resp = urllib.request.urlopen(pkg['href'])
                except urllib.error.HTTPError:
                    continue

                charset = resp.info().get_param('charset')
                soup = BeautifulSoup(resp,
                                     from_encoding=charset,
                                     features='html.parser')

                if pkg['pkg_name'] == 'libx11':
                    ###
                    # пакеты входящие в состав пакета 'xorg-libraries'
                    ###
                    # ищем на странице тег <code> и в нем pkg_name-x.x.x.tar.
                    code_content = soup.findAll('code')[0].contents[0]
                    pattern = re.compile(pkg['pkg_name'] + r'-([^\s]+).tar',
                                         flags=re.IGNORECASE)
                    result = re.search(pattern, code_content)
                    new_version = result.group(1)
                else:
                    new_version = soup.find_all('h1')
                    if not new_version:
                        new_version = '???'
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

        link_color = clrs['lblue'] if '://' in pkg['href'] else clrs['grey']
        print(('{0}{1}{2}{3}{4}'
               '{5}{6}').format(color,
                                pkg['pkg_name'],
                                ' ' * (max_len - len(pkg['pkg_name']) + 7),
                                update,
                                link_color,
                                pkg['href'],
                                clrs['reset']))


main()
