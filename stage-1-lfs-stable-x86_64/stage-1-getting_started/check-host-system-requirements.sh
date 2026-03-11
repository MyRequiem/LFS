#!/bin/bash

# Simple script to list version numbers of critical development tools
# https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html

export LC_ALL=C

clear_console(){
# shellcheck disable=SC2034
    read -r JUNK
    unset JUNK
    clear
}

echo -e "###\n# List version numbers of critical development tools\n###\n"

### Bash
echo "Bash version: $(bash --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=3.2"

# /usr/bin/sh should be a symbolic or hard link to bash
MYSH="$(readlink -f /usr/bin/sh)"
echo "${MYSH}" | grep -q bash || {
    echo "ERROR: /usr/bin/sh should be a symbolic or hard link to bash"
    exit 1
}
ls -l /usr/bin/sh
unset MYSH
clear_console

### Binutils
echo "Binutils version: $(ld --version | head -n 1 | cut -d ' ' -f 5)"
echo "Required: >=2.13.1"
echo "Version >2.46.0 not recommended"
clear_console

### Bison
echo "Bison version: $(bison --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=2.7"
# /usr/bin/yacc should be a link to bison or a small script that executes bison
if [ -L /usr/bin/yacc ]; then
    ls -l /usr/bin/yacc
elif [ -x /usr/bin/yacc ]; then
    echo "/usr/bin/yacc version: $(yacc -V | head -n 1 | cut -d ' ' -f 4)"
else
    echo "ERROR: /usr/bin/yacc (from Bison) not found"
    exit 1
fi
clear_console

### Coreutils
echo "Coreutils version: $(chown --version | head -n 1 | cut -d ' '  -f 4)"
echo "Required: >=8.1"
clear_console

### Diffutils
echo "Diffutils version: $(diff --version | head -n 1 | cut -d ' '  -f 4)"
echo "Required: >=2.8.1"
clear_console

### Findutils
echo "Findutils version: $(find . --version | head -n 1 | cut -d ' '  -f 4)"
echo "Required: >=4.2.31"
clear_console

### Gawk
echo "Gawk version: $(gawk -V | head -n 1 | cut -d ' ' -f 3 | cut -d , -f 1)"
echo "Required: >=4.0.1"
# /usr/bin/awk should be a link to gawk
if [ -L /usr/bin/awk ]; then
    ls -l /usr/bin/awk
elif [ -x /usr/bin/awk ]; then
    echo "/usr/bin/awk version: $(/usr/bin/awk --version | head -n 1 | \
        cut -d ' ' -f 3 | cut -d , -f 1)"
else
    echo "ERROR: awk not found"
    exit 1
fi
clear_console

### GCC, G++
echo "GCC version: $(gcc --version | head -n 1 | cut -d ' ' -f 3)"
echo "G++ version: $(g++ --version | head -n 1 | cut -d ' ' -f 3)"
echo "Required: >=5.4"
echo "Version >15.2.0 not recommended"
clear_console

### Grep
echo "Grep version: $(grep --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=2.5.1a"
clear_console

### Gzip
echo "Gzip version: $(gzip --version | head -n 1 | cut -d ' ' -f 2)"
echo "Required: >=1.3.12"
clear_console

### Linux Kernel
echo "Linux Kernel: $(uname -r)"
echo "Required: >=5.4"
clear_console

### M4
echo "M4 version: $(m4 --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=1.4.10"
clear_console

### Make
echo "Make version: $(make --version | head -n 1 | cut -d ' ' -f 3)"
echo "Required: >=4.0"
clear_console

### Patch
echo "Patch version: $(patch --version | head -n 1 | cut -d ' ' -f 3)"
echo "Required: >=2.5.4"
clear_console

### Perl
echo "Perl version: $(perl -V:version | cut -d \' -f 2)"
echo "Required: >=5.8.8"
clear_console

### Python3
echo "Python3 version: $(python3 --version | cut -d ' ' -f 2)"
echo "Required: >=3.4"
clear_console

### Sed
echo "Sed version: $(sed --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=4.1.5"
clear_console

### Tar
echo "Tar version: $(tar --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=1.22"
clear_console

### Texinfo
echo "Texinfo version: $(makeinfo --version | head -n1 | cut -d ' ' -f 4)"
echo "Required: >=5.0"
clear_console

### Xz
echo "Xz version: $(xz --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=5.0.0"
clear_console

echo "=== Compilation tools test ==="
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
