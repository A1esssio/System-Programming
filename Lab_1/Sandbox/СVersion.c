#include <stdio.h>   // для puts()
#include <stdlib.h>  // для exit()

int main() {
    // Аналог вывода сообщения (более привычный способ в C)
    puts("Alesssio Galesssio Vladimiro");  // puts автоматически добавляет \n

    // Завершение программы
    return 0;  // Аналог exit(0), но более идиоматично для main()
}

/*
# compilation with gcc
gcc name.c -o name

# give permition to call
chmod +x name

# call
./name
*/