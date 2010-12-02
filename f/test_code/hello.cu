#include <stdio.h>
#include <iostream>
#include "common/book.h"
/*
To summarize, host pointers can access memory from host code, and device pointers can access memory from
device code.
You can pass pointers allocated with cudaMalloc() to functions that
execute on the device.
You can use pointers allocated with cudaMalloc()to read or write
memory from code that executes on the device.
You can pass pointers allocated with cudaMalloc()to functions that
execute on the host.
You cannot use pointers allocated with cudaMalloc()to read or write
memory from code that executes on the host.
*/

//This kernel function will run in the device
__global__ void add ( int a, int b, int *c ) {
	*c = a + b;
}

int main ( void  ) {
	int  c;
	int *dev_c;
	
	//pointer to a pointer and sizeof
	HANDLE_ERROR( cudaMalloc ( (void**) &dev_c, sizeof(int) ) );

	//kernel call
	add<<<1,1>>>( 5, 26, dev_c);

	HANDLE_ERROR( cudaMemcpy ( &c, dev_c, sizeof(int), cudaMemcpyDeviceToHost ) );
	printf( "5 + 26 = %d\n", c);
	cudaFree (dev_c);

	return 0;
}
