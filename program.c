//TODO remember to outcomment/remove all printf's!

#include <stdint.h> //fixed length integer types
#include <stdio.h>  //printf and more
#include <stdlib.h> //TODO cmnt OUT, contains malloc

//  Define busywait constants

//  Define I/O addresses
#define def_led_addr  0x00000000 //TODO cmnt IN
//#define def_sw_addr   0x00000001


void busywait();                        //change number in for-loop to change length.
void simpleblink(uint32_t* led_addr);   //simple program: blink one LED
//void fancyblink(uint32_t* led_addr);    //kinda simple program: blink LED's one at a time

int main(){

    uint32_t* led_addr = def_led_addr;                  //TODO cmnt IN
    //uint32_t* led_addr = malloc(sizeof(uint32_t));    //TODO cmnt OUT
    //printf("\nledaddr: %x \n", led_addr);
    //printf("ledstart: %x \n\n", *led_addr);

    //Put program to run here:
    simpleblink(led_addr);


}


//  Current val: 10
void busywait(){
    uint32_t i = 0;
    while (i<10){
        i++;
    }
};

//simple program: blink one LED
void simpleblink(uint32_t* led_addr){
    for (int i=0;i<5;i++){
        *led_addr = 1;
        //printf("led: %x \n",*led_addr);
        busywait();
        *led_addr = 0;
        //printf("led: %x \n\n",*led_addr);
        busywait();
    }
}

//kinda simple program: blink LED's one at a time
void fancyblink(uint32_t* led_addr){
    *led_addr = 1;
    printf("led: %x \n",*led_addr);
    busywait();

}

/*
void fibonnaci(){
uint32_t max = 2;

}

void factorial(){

}


*/
