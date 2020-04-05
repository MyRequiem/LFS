#!/bin/bash

# Simple script to list version numbers of critical development tools
# http://www.linuxfromscratch.org/lfs/view/9.0/chapter02/hostreqs.html

export LC_ALL=C
bash --version | head -n1 | cut -d ' ' -f 2-4

MYSH="$(readlink -f /bin/sh)"
echo "/bin/sh -> ${MYSH}"
echo "${MYSH}" | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

echo -n "Binutils: "
ld --version | head -n1 | cut -d ' ' -f 3-
bison --version | head -n1

if [ -L /usr/bin/yacc ]; then
    echo "/usr/bin/yacc -> $(readlink -f /usr/bin/yacc)";
elif [ -x /usr/bin/yacc ]; then
    echo "yacc is $(/usr/bin/yacc --version | head -n1)"
else
    echo "yacc not found"
fi

bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d ' ' -f 1,6-
echo -n "Coreutils: "
chown --version | head -n1 | cut -d ")" -f 2
diff --version | head -n1
find . --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
    echo "/usr/bin/awk -> $(readlink -f /usr/bin/awk)";
elif [ -x /usr/bin/awk ]; then
    echo "awk is $(/usr/bin/awk --version | head -n1)"
else
    echo "awk not found"
fi

gcc --version | head -n1
g++ --version | head -n1
echo -n "Glibc vesion: "
GLIBC_VERSION="$(ldd --version | head -n1 | cut -d " " -f 2-)"
echo "${GLIBC_VERSION}"
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo "Perl vesion: $(perl -V:version | cut -d \' -f 2)"
echo "Python3 version: $(python3 --version | cut -d ' ' -f 2)"
sed --version | head -n1
tar --version | head -n1
echo "Texinfo vesion: $(makeinfo --version | head -n1 | cut -d ' ' -f 2-)"
xz --version | head -n1
echo ""
echo "# creating simple C-file dummy.c"
echo "echo 'int main(){}' > dummy.c"
echo 'int main(){}' > dummy.c
echo "# compiling dummy.c (generate a.out)"
echo "g++ -o dummy dummy.c"
g++ -o dummy dummy.c

if [ -x dummy ]; then
    echo "g++ compilation OK";
else
    echo "g++ compilation failed";
fi

rm -f dummy.c dummy
