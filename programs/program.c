

//TODO cmnt OUT all includes!
//#include <stdio.h>  //printf and more
//#include <stdlib.h> //

//  Define busywait constants
// ...

//TODO cmnt section IN vvv
//  Define I/O addresses
#define def_led_addr  0x00000000
//#define def_sw_addr   0x00000001

asm("li sp, 0x100000"); // SP set to 1 MB
asm("jal main");        // call main
asm("ecall");           // make ecall
//TODO cmnt section IN ^^^

//void printtestvars(int* led_addr);           //TODO outcomment before compiling
void busywait();                        //change number in for-loop to change length.
void simpleblink(int* led_addr);   //simple program: blink one LED
//void fancyblink(int* led_addr);    //kinda simple program: blink LED's one at a time

int main(){

    int* led_addr = def_led_addr;                  //TODO cmnt IN
    //int* led_addr = malloc(sizeof(int));          //TODO cmnt OUT
    //printf("\nledaddr: %x \n", led_addr);
    //printf("ledstart: %x \n\n", *led_addr);

    //Put program to run here:
    for (int i=0;i<5;i++){
        *led_addr = 1;
        //printtestvars(led_addr);
        busywait();
        *led_addr = 0;
        //printtestvars(led_addr);
        busywait();
    }


}


//  Current val: 10
void busywait(){
    int i = 0;
    while (i<10){
        i++;
    }
}

/*
void printtestvars(int* led_addr){
    printf("led: %x \n",*led_addr);

}
*/

// vvv PROGRAMS vvv

//simple program: blink one LED
/*
void simpleblink(int* led_addr){
    for (int i=0;i<5;i++){
        *led_addr = 1;
        //printtestvars(led_addr);
        busywait();
        *led_addr = 0;
        //printtestvars(led_addr);
        busywait();
    }
}
*/
/*
//kinda simple program: blink LED's one at a time
void fancyblink(int* led_addr){
    *led_addr = 1;
    //printf("led: %x \n",*led_addr);
    busywait();

}
void fibonnaci(){
int max = 2;

}

void factorial(){

}
*/
