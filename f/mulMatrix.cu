#include <stdio.h>
#include <cuda.h>
#include "cuda_runtime_api.h"
#include <stdint.h>
#include <stdlib.h>

//#define Width 4

//Matrix multiplication kernel
__global__ void MatrixMulKernel ( float  *Md, float *Nd, float *Pd, int Width ){
	//2D thread ID
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	//Pvalue stores Pd element computed by thread
	float Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		float Mdelement = Md[ ty * Width + k ];
		float Ndelement = Nd[ k * Width + tx ];
		Pvalue += Mdelement * Ndelement;
	}

	//Write matrix to device memory; each thread writes one element
	Pd[ ty * Width + tx  ] = Pvalue;
}

void MatrixMul( float *M, float *N, float  *P, int Width ){
	int size = Width * Width * sizeof( float );
	float *Md, *Nd, *Pd;

	//Transfer M, N to device
	cudaMalloc( (void**) &Md, size );
	cudaMemcpy( Md, M, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Nd, size );
        cudaMemcpy( Nd, N, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Pd, size );
	
	//invoke kernel
	dim3 dimBlock( Width, Width );
	dim3 dimGrid( 1, 1 );
	
	//Launch kernel
	MatrixMulKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );

	//transfer from device to host
	cudaMemcpy( P, Pd, size, cudaMemcpyDeviceToHost );

	//Print matrix P
	for ( int w = 0; w < Width * Width; w++ ){
		printf( "\n" );
		printf( " %d: %f  ", w, P[w] );
		printf( "\n" );
	}

	//Free device matrices
	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd );
}

int main ( void ) {
	int Width = 4;
	float A[ Width * Width ];

	for ( int x = 0; x < Width * Width; x++ ){
		A[ x ] = 2;
	}
	
	float B[ Width * Width ];
	for ( int z = 0; z < Width * Width; z++ ){
		B[ z ] = 2;
	}
	
	float C[ Width * Width ];
	//= { 1, 1, 1, 1,1,1,1,1,1,1,1,1,1,1,1,1  };
	//float B[ Width * Width ] = { 1, 1, 1, 1,1,1,1,1,1,1,1,1,1,1,1,1  };
	//float C[ Width * Width ] = { 1, 1, 1, 1,1,1,1,1,1,1,1,1,1,1,1,1  };

	MatrixMul( A, B, C, Width );
}

void printMatrix ( float *A, float *B, float *C, int Width, int Height ){
	
}
