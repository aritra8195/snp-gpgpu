#include <stdio.h>
//#include <cuda.h>
//#include "cuda_runtime_api.h"
//#include <stdint.h>
//#include <stdlib.h>

//This is the working matrix multiplication code - very basic
/*
Done:
- printing of matrix in a more pleasant manner using printMatrix function
- command line arguments
- opens matrix files and reads the matrix successfully
- working array passing from main to auxiliary (loadMatrixFile) function :)
- fixed printing of matrix
- fixed erroneous matrix values by moving loading into host matrix multiplication function!
- basic move towards SN P simulation: multiplication of s0 and Msnp
- moving from multiplication to finally simulating an SNP (sort of)

Problems:
- (fixed)  MatA and MatB values are overlapping and erroneous
*/


// START of AUXILIARY functions

//START vector addition kernel function
__global__ void MatrixAddKernel ( int  *Md, int *Nd, int *Pd, int N ){
        int tid = blockIdx.x; //thred id
	if ( tid < N )
		Pd[ tid ] = Md[ tid ] + Nd[ tid ];
/*        int tx = threadIdx.x;
	int ty = threadIdx.y;
	int Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ k * Width + tx ];
		Pvalue = Mdelement + Ndelement;
	}
        Pd[ ty * Width + tx  ] = Pvalue; */
}							
//END of kernel addition


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


//function to print matrix
void printMatrix ( int *M, int rows, int columns ){
	//assumes matrix is in row-major format
	int index;
	printf ( "\n \n " );
	for ( int v = 0; v < rows; v++  ){
	//assumes a square matrix
		for ( int w = 0; w < columns; w++   ) {
			index = v * columns + w;
			printf ( " %02d", M[ index ]  );
		}
		printf ( " \n\n " );
	}
}//End of printMatrix function


//START of loadMatrixFile
void loadMatrixFile( char *filename, int *z, int matWidth, int matHeight ){
	int y = 0;
	int w = 0;
	int x;
	int offset = 0;
	FILE *ptr1 = fopen( filename, "r" );
//	int *z = ( int * )malloc( sizeof( ( matWidth * matHeight ) ) );
	//int z[ ( matWidth * matHeight ) + offset ] ;
	fscanf( ptr1, " %d", &x  );
	while( !feof( ptr1 ) && y < ( matWidth * matHeight ) + 1 ){
		if ( y > offset ){
			fscanf( ptr1, " %d", &z[ w - offset ]  );
			//printf( " B: z[ %d ]: %d \n", w, z[ w - offset ] );
			w++;
		}
		else{
			fscanf( ptr1, " %d", &x );
		}
		y++;
	}
	fclose( ptr1 );
//	x = y = w = 0;
//	array = &z[ 0 ];
//	free( z );
}
//END of loadMatrixFile


//Start of matrix multiplication host function MatrixMul
void MatrixMul( char *filename0, char *filename1, char *filename2, int Width /*, int *M, int *N, int  *P, int Width*/ ){
	int size = Width * Width * sizeof( int );
	int *Md, *Nd, *Pd;

	dim3 dimBlock( Width, Width );
	dim3 dimGrid( 1, 1 );

	int *matA = ( int * )malloc( size );
	//printf( "Width and height of Matrix A: %d %d and init values are\n", Width, Width );
	//printMatrix( matA, Width, Width );
	loadMatrixFile( filename1, matA, Width, Width );

	printf( " \ns after loading from file: \n" );
	printMatrix( matA, Width, Width );
			
	int *matB = ( int * )malloc( size );
	loadMatrixFile( filename2, matB, Width, Width );
		
	printf( " \nM after loading from file: \n" );
	printMatrix( matB, Width, Width );
			
	//assumes a square matrix
	int *matC = ( int * )malloc( size );
	
	cudaMalloc( (void**) &Md, size );
	cudaMemcpy( Md, matA, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Nd, size );
        cudaMemcpy( Nd, matB, size, cudaMemcpyHostToDevice );
	cudaMalloc( (void**) &Pd, size );	
	
	MatrixMulKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );
	//MatrixAddKernel<<< N, 1 >>>( Md, Nd, Pd );

	cudaMemcpy( matC, Pd, size, cudaMemcpyDeviceToHost );

	printf( " \ns * M: \n" );
	printMatrix( matC, Width, Width );

	free( matA ); free( matB ); free( matC );
	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd );
}
//End of Matrix multiplication function MatrixMul


//END of AUXILIARY functions


//START of MAIN function
int main ( void ) {
	int x;
	while( x != 3) {
		printf( "\n Type \n 1 to enter filenames < 20 in length \n 2 for 2 \n 3 to quit \n: " );
		scanf( "%d", &x );
		switch( x ){
			case 1:
				char a[ 20 ], b[ 20 ], c[ 20 ];
				int d;
				printf( " Please enter spiking vector file: \n" );
				scanf( " %s", &a );
				printf( " Please enter configuration vector file: \n" );
				scanf( " %s", &b );
				printf( " Please enter spiking transition matrix file: \n" );
				scanf( " %s", &c ); 
				printf( " Please enter the square matrix width: \n" );
				scanf( " %d", &d ); 

				if( ( strlen( a ) ) > 20 && ( strlen( b ) ) > 20 && ( strlen( c ) ) > 20  ) {
					printf( " Filename/s was/were too long ( > 20 char )  " );
					// Do something about segmentation fault here
					//spikVec = { "\0" }; // doesn't work
					//*confVec = NULL; // doesn't work
					break;
				}
				else {
					printf( " You entered the file %s for the spiking vector \n", a );
					printf( " You entered the file %s for the configuration vector \n", b );
					printf( " You entered the file %s for the spiking transition matrix \n ", c );
					char *confVec = b;
					char *spikVec = a;
					char *spikTransMat = c;
					int width = d;
		
					printf( "\nYou have entered files %s, %s, and %s and square matrix width %d \n", spikVec, confVec, spikTransMat, width );

					//load matrices from files
					FILE *ptr1 = fopen( confVec, "r" );
					FILE *ptr2 = fopen( spikVec, "r" );
					FILE *ptr3 = fopen( spikTransMat, "r" );

					if ( ptr1 == 0 && ptr2 == 0 && ptr3 == 0 )
						printf( "\n could not open one of the following files: %s %s %s \n", a, b, c );
					else {
						MatrixMul( confVec, spikVec, spikTransMat, width );
					}
					fclose( ptr1 ); fclose( ptr2 ); fclose( ptr3 );
					break;				
				}
			case 2: 
				printf( " You entered 2 \n" );
				break;
			case 3: 
				printf( " You entered quit. Bye! \n" );
				break;
			default:
				printf( " You entered an invalid choice \n" );
				break;
		}

	}
}
//END of MAIN function
