## How to compile with external libraries (Ncurses)

1) fasm file.asm file.o
2) ld file.o -o file -lc -lncurses -ltinfo -dynamic-linker /lib64/ld-linux-x86-64.so.2
