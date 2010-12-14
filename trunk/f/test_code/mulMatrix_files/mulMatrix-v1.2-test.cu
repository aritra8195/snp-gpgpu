#include <stdio.h>
#include <cuda.h>
#include "cuda_runtime_api.h"
#include <stdint.h>
#include <stdlib.h>

//This is the working matrix multiplication code - very basic
/*
Done:
- printing of matrix in a more pleasant manner using printMatrix function
- getting commandline arguments
*/


// START of Auxiliary functions

//Start of kernel multiplication
__global__ void MatrixMulKernel ( int  *Md, int *Nd, int *Pd, int Width ){
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	int Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ k * Width + tx ];
		Pvalue += Mdelement * Ndelement;
	}

	Pd[ ty * Width + tx  ] = Pvalue;
}
//End of kernel multiplication

//Start of matrix multiplication host function
void MatrixMul( int *M, int *N, int  *P, int Width ){
	int size = Width * Width * sizeof( int );
	int *Md, *Nd, *Pd;

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
//End of Matrix multiplication function

//function to print matrix
void printMatrix ( int *M, int rows, int columns ){
	//assumes matrix is in row-major format
	printf ( "\n %s: \n", "M" );
	for ( int v = 0; v < rows; v++  ){
	//assumes a square matrix
		for ( int w = 0; w < columns; w++   ) {
			printf ( " %03d ", M[ v * columns + w ]  );
		}
		printf ( " \n " );
	}
}//End of printMatrix function

//END of Auxiliary functions


//START of Main function
int main ( int argc, char *argv[ ] ) {
	
	if ( argc != 3 ) {
		printf( "\nusage: %s matrixFile1 matrixFile2 \n\n", argv [ 0 ] );
	}
	else {
		char *filename1 = argv[ 1 ];
		char *filename2 = argv[ 2 ];
		int *matA; //holds 1st matrix
		int *matB; //holds 2nd matrix
		
		matA = ( int * ) malloc( sizeof ( int ) );
		matB = ( int * ) malloc( sizeof ( int ) );

		printf( "you have entered files %s and %s \n", filename1, filename2 );
		free( matA ); free( matB );
	}

	int Width = 4;
	
	int A[ Width * Width ];

	for ( int x = 0; x < Width * Width; x++ ){
		A[ x ] = 2;
	}
	
	int B[ Width * Width ];
	for ( int z = 0; z < Width * Width; z++ ){
		B[ z ] = 2;
	}
	
	int C[ Width * Width ];

	//MatrixMul( A, B, C, Width );
	//printMatrix( C, Width, Width );
}
//END of Main function
