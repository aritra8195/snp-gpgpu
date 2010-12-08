#include <stdio.h>
#include <cuda.h>
#include "cuda_runtime_api.h"
#include <stdint.h>
#include <stdlib.h>

// DO NOT EDIT THIS!!!
//This is the working matrix multiplication code - very basic

//#define Width 4

__global__ void MatrixMulKernel ( float  *Md, float *Nd, float *Pd, int Width ){
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	float Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		float Mdelement = Md[ ty * Width + k ];
		float Ndelement = Nd[ k * Width + tx ];
		Pvalue += Mdelement * Ndelement;
	}

	Pd[ ty * Width + tx  ] = Pvalue;
}

void MatrixMul( float *M, float *N, float  *P, int Width ){
	int size = Width * Width * sizeof( float );
	float *Md, *Nd, *Pd;

	cudaMalloc( (void**) &Md, size );
	cudaMemcpy( Md, M, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Nd, size );
        cudaMemcpy( Nd, N, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Pd, size );
	
	dim3 dimBlock( Width, Width );
	dim3 dimGrid( 1, 1 );
	
	MatrixMulKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );

	cudaMemcpy( P, Pd, size, cudaMemcpyDeviceToHost );

	for ( int w = 0; w < Width * Width; w++ ){
		printf( "\n" );
		printf( " %d: %f  ", w, P[w] );
		printf( "\n" );
	}

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

	MatrixMul( A, B, C, Width );
}

