#include <stdio.h>
//#include <cuda.h>
//#include "cuda_runtime_api.h"
//#include <stdint.h>
//#include <stdlib.h>

//This is the working matrix multiplication code - very basic
/****

Done:
- printing of matrix in a more pleasant manner using printMatrix function
- command line arguments
- opens matrix files and reads the matrix successfully
- working array passing from main to auxiliary (loadMatrixFile) function :)
- fixed printing of matrix
- fixed erroneous matrix values by moving loading into host matrix multiplication function!
- basic move towards SN P simulation: multiplication of s0 and Msnp
- moving from multiplication to finally simulating an SN P (sort of) in a very basic manner
- MatrixAddKernel now works :)

Problems:
- (fixed)  MatA and MatB values are overlapping and erroneous

TODOS:
- error checking of switch case input ( scanf of int and char )
- use multiple files + make file
- see code comments

****/


/***
**** START of AUXILIARY functions
***/

/*
START of KERNEL functions
*/
//START vector addition kernel function
__global__ void MatrixAddKernel ( int  *Md, int *Nd, int *Pd, int Width ){
	// MatrixAddKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );
	//dim3 dimBlock( Width, Width ); dim3 dimGrid( 1, 1 );
	//int tx = threadIdx.x;
	int ty = threadIdx.y;
	//due to row-major ordering of matrix elements
	//int Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ ty * Width + k ];
		Pd[ ty * Width + k ] = Mdelement + Ndelement;
	}
	//Pd[ ty * Width + tx  ] = Pvalue;
}							
//END of kernel addition


//START of kernel multiplication
__global__ void MatrixMulKernel ( int  *Md, int *Nd, int *Pd, int Width ){
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	//due to row-major ordering of matrix elements
	int Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ k * Width + tx ];
		Pvalue += Mdelement * Ndelement;
	}
	Pd[ ty * Width + tx  ] = Pvalue; 
}
//END of kernel multiplication


/*
END of KERNEL functions
*/


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
	fscanf( ptr1, " %d", &x  );
	while( !feof( ptr1 ) && y < ( matWidth * matHeight ) + 1 ){
		if ( y > offset ){
			fscanf( ptr1, " %d", &z[ w - offset ]  );
			w++;
		}
		else{
			fscanf( ptr1, " %d", &x );
		}
		y++;
	}
	fclose( ptr1 );
}
//END of loadMatrixFile


//Start of matrix multiplication host function MatrixMul
//prototype: MatrixMul( confVec, spikVec, spikTransMat, width );
void MatrixMul( char *filename0, char *filename1, char *filename2, int Width ){
	int size = Width * Width * sizeof( int );
	int *Md, *Nd, *Od, *Pd, *Qd;

	dim3 dimBlock( Width, Width );
	dim3 dimGrid( 1, 1 );

	int *matA = ( int * )malloc( size );//spikVec
	loadMatrixFile( filename1, matA, Width, Width );
	printf( " \n%s after loading from file: \n", filename1 );
	printMatrix( matA, Width, Width );
			
	int *matB = ( int * )malloc( size );//spikTransMat
	loadMatrixFile( filename2, matB, Width, Width );		
	printf( " \n%s after loading from file: \n", filename2 );
	printMatrix( matB, Width, Width );

	int *matD = ( int * )malloc( size );//confVec
	loadMatrixFile( filename0, matD, Width, Width );		
	printf( " \n%s after loading from file: \n", filename0 );
	printMatrix( matD, Width, Width );
			
	//assumes a square matrix
	int *matC = ( int * )malloc( size );
	int *matE = ( int * )malloc( size );
	
	cudaMalloc( ( void** ) &Md, size );//spikVec
	cudaMemcpy( Md, matA, size, cudaMemcpyHostToDevice );

	cudaMalloc( ( void** ) &Nd, size );//spikTransMat
        cudaMemcpy( Nd, matB, size, cudaMemcpyHostToDevice );

	//Ck = spikVec * spikTransMat
	cudaMalloc( ( void** ) &Pd, size );	

	cudaMalloc( ( void** ) &Od, size );//confVec	

        cudaMemcpy( Od, matD, size, cudaMemcpyHostToDevice );
	
	// final matrix: Ck+1 = confVec + Ck
	cudaMalloc( ( void** ) &Qd, size );
	
	// Ck = spikVec * spikTransMat => Pd = Md * Nd
	MatrixMulKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );

//	cudaMemcpy( matE, Qd, size, cudaMemcpyDeviceToHost );
//	printf( " \n%s * %s : \n", filename1, filename2 );
//	printMatrix( matC, Width, Width );

	// Ck+1 = confVec + Ck => Qd = Od + Pd
	MatrixAddKernel<<< dimGrid, dimBlock >>>( Od, Pd, Qd, Width );

	cudaMemcpy( matE, Qd, size, cudaMemcpyDeviceToHost );
	printf( " \n%s + %s * %s : \n", filename0, filename1, filename2 );
	printMatrix( matE, Width, Width );

	free( matA ); free( matB ); free( matC ); free( matD ); free( matE );
	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd ); cudaFree( Od ); cudaFree( Qd );
}
//End of Matrix multiplication function MatrixMul


/***
****END of AUXILIARY functions
****/




/***
****START of MAIN function
****/
int main ( void ) {
	int x;
	while( x != 2 ) {
		printf( "\n Type \n 1 to enter filenames < 20 in length \n 2 to quit \n: " );
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
					// TODO: Do something about segmentation fault here when input filename is > 20 chars
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

					if ( ptr1 == 0 && ptr2 == 0 && ptr3 == 0 ) {
						printf( "\n could not open one of the following files: %s %s %s \n", a, b, c );
						break;
					}
					else {
						MatrixMul( confVec, spikVec, spikTransMat, width );
					}
					fclose( ptr1 ); fclose( ptr2 ); fclose( ptr3 );
					break;				
				}
			case 2: 
				printf( " You entered quit. Bye! \n\n" );
				break;
			default:
				printf( " You entered an invalid choice \n\n" );
				break;
		}
	}
}
/***
****END of MAIN function
***/
