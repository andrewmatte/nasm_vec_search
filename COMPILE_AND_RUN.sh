nasm -f elf64 hello.asm -o hello.o && ld hello.o -o program -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 && time ./program
