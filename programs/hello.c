asm("li sp, 0x100000"); // SP set to 1 MB
asm("jal main");        // call main
// asm("li a7, 10");       // prepare ecall exit
// asm("ecall");           // now your simulator should stop

#define MEM 0x000000

int main() {
    int n = 1;
    n = n + 1;

    *((int*)MEM) = n;
}
