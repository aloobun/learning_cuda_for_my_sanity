#include<iostream>

__global__ void kernel(void){ //
}

int main (void){
    kernel<<<1,1>>>(); //one block, one thread
    printf("hello world\n");
    return 0;
}
