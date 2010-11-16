#include <stdio.h>
#include <iostream>

__global__ void kernel ( void) {

}

int main (void) {
	kernel<<<1,1>>>();
	printf (" Hello world of C!\n");
	return 0;
}
