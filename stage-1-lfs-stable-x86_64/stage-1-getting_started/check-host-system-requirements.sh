#!/bin/bash

# Simple script to list version numbers of critical development tools
# https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html

export LC_ALL=C

echo -e "###\n# List version numbers of critical development tools\n###\n"

### Bash
echo "Bash: $(bash --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=3.2"

# /bin/sh should be a symbolic or hard link to bash
MYSH="$(readlink -f /bin/sh)"
echo "${MYSH}" | grep -q bash || {
    echo "ERROR: /bin/sh should be a symbolic or hard link to bash"
    exit
}
echo -e "/bin/sh -> ${MYSH}\n"
unset MYSH

### Binutils
echo "Binutils: $(ld --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=2.13.1"
echo -e "Version >2.40 not recommended\n"

### Bison
echo "Bison: $(bison --version | head -n 1 | cut -d ' ' -f 4)"
echo "Required: >=2.7"
# /usr/bin/yacc should be a link to bison or a small script that executes bison
if [ -L /usr/bin/yacc ]; then
    echo -e "/usr/bin/yacc -> $(readlink -f /usr/bin/yacc)\n";
elif [ -x /usr/bin/yacc ]; then
    echo -e "/usr/bin/yacc: $(yacc --version | head -n 1 | cut -d ' ' -f 4)\n"
else
    echo -e "\nERROR: /usr/bin/yacc (from Bison) not found\n"
    exit
fi

### Coreutils
echo "Coreutils: $(chown --version | head -n 1 | cut -d ' '  -f 4)"
echo -e "Required: >=6.9\n"

### Diffutils
echo "Diffutils: $(diff --version | head -n 1 | cut -d ' '  -f 4)"
echo -e "Required: >=2.8.1\n"

### Findutils
echo "Findutils: $(find . --version | head -n 1 | cut -d ' '  -f 4)"
echo -e "Required: >=4.2.31\n"

### Gawk
echo "Gawk: $(gawk --version | head -n 1 | cut -d ' ' -f 3 | cut -d , -f 1)"
echo "Required: >=4.0.1"
# /usr/bin/awk should be a link to gawk
if [ -h /usr/bin/awk ]; then
    echo -e "/usr/bin/awk -> $(readlink -f /usr/bin/awk)\n";
elif [ -x /usr/bin/awk ]; then
    echo -e "/usr/bin/awk version: $(/usr/bin/awk --version | head -n 1 | \
        cut -d ' ' -f 3 | cut -d , -f 1)\n"
else
    echo -e "ERROR: awk not found\n"
fi

### GCC, G++
echo "GCC: $(gcc --version | head -n 1 | cut -d ' ' -f 3)"
echo "G++: $(g++ --version | head -n 1 | cut -d ' ' -f 3)"
echo "Required: >=5.1"
echo -e "Version >12.2.0 not recommended\n"

### Grep
echo "Grep: $(grep --version | head -n 1 | cut -d ' ' -f 4)"
echo -e "Required: >=2.5.1a\n"

### Gzip
echo "Gzip: $(gzip --version | head -n 1 | cut -d ' ' -f 2)"
echo -e "Required: >=1.3.12\n"

### Linux Kernel
echo "Linux Kernel: $(uname -r)"
echo -e "Required: >=3.2\n"

### M4
echo "M4: $(m4 --version | head -n 1 | cut -d ' ' -f 4)"
echo -e "Required: >=1.4.10\n"

### Make
echo "Make: $(make --version | head -n 1 | cut -d ' ' -f 3)"
echo -e "Required: >=4.0\n"

### Patch
echo "Patch: $(patch --version | head -n 1 | cut -d ' ' -f 3)"
echo -e "Required: >=2.5.4\n"

### Perl
echo "Perl: $(perl -V:version | cut -d \' -f 2)"
echo -e "Required: >=5.8.8\n"

### Python3
echo "Python3: $(python3 --version | cut -d ' ' -f 2)"
echo -e "Required: >=3.4\n"

### Sed
echo "Sed: $(sed --version | head -n 1 | cut -d ' ' -f 4)"
echo -e "Required: >=4.1.5\n"

### Tar
echo "Tar: $(tar --version | head -n 1 | cut -d ' ' -f 4)"
echo -e "Required: >=1.22\n"

### Texinfo
echo "Texinfo: $(makeinfo --version | head -n1 | cut -d ' ' -f 4)"
echo -e "Required: >=4.7\n"

### Xz
echo "Xz: $(xz --version | head -n 1 | cut -d ' ' -f 4)"
echo -e "Required: >=5.0.0\n"

echo "=== Compilation tools test ==="
echo "# creating simple C-file dummy.c"
echo "echo 'int main(){}' > dummy.c"
echo 'int main(){}' > dummy.c
echo "# compiling dummy.c (generate a.out)"
echo "g++ -o dummy dummy.c"
g++ -o dummy dummy.c

if [ -x dummy ]; then
    echo -e "g++ compilation OK\n";
else
    echo -e "g++ compilation failed\n";
fi

rm -f dummy.c dummy
