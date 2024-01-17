#include <stdint.h> //fixed length integer types
#include <stdio.h>  //printf and more

#define led_addr 0x00001000

int main(){

uint32_t hex = led_addr;
// simple program: blink one LED
printf("%x", led_addr);

}


/*
void fibonnaci(){
uint32_t max = 2;

}

void factorial(){

}


*/
