//#include "book.h"
#include <stdio.h>

#define N 10

//kernel function to add 2 vectors. These functions can be called
// from the host/device, but will run on the device only
__global__ void add( int *a, int *b, int *c ) {
	int tid = blockIdx.x; //thred id
	if ( tid < N )
		c[tid] =a[tid] + b[tid];
}

int main( void ) {
	int /*a[N], b[N],*/ c[N];
	int *dev_a, *dev_b, *dev_c;
	// allocate the memory on the GPU
	HANDLE_ERROR( cudaMalloc( (void**)&dev_a, N * sizeof(int) ) );
	HANDLE_ERROR( cudaMalloc( (void**)&dev_b, N * sizeof(int) ) );
	HANDLE_ERROR( cudaMalloc( (void**)&dev_c, N * sizeof(int) ) );
	// fill the arrays 'a' and 'b' on the CPU
	int a[N] = { 1, 1, 2, 2, 4, 4, 5, 5, 6, 6  };
	int b[N] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
	/*for (int i=0; i<N; i++) {
		a[i] = -i;
		b[i] = i * i;
	}*/
	// copy the arrays 'a' and 'b' to the GPU
	HANDLE_ERROR( cudaMemcpy( dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice) );
	HANDLE_ERROR( cudaMemcpy( dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice) );
	//call kernel function,run kernel function on N blocks 
	add<<<N, 1>>>( dev_a, dev_b, dev_c );
	//copy array 'c' from GPU to CPU for printing etc
	HANDLE_ERROR( cudaMemcpy( c, dev_c, N * sizeof( int), cudaMemcpyDeviceToHost ) );
																				
																						//display results
																						for (int i = 0; i < N; i++){
		printf( "\n %d  + %d = %d\n ", a[i], b[i], c[i] );
	}
																						//free memory allocated on the GPU
		cudaFree( dev_a );
		cudaFree( dev_b );
		cudaFree( dev_c );

	return 0;
																					}
