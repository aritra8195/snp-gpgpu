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
- Can now do Ck+1 = Ck + sk * M :)
- outputs Ck+1 to a file whose filename is entered by the user

Problems:
- (fixed)  MatA and MatB values are overlapping and erroneous

TODOS:
- write Ck+1 to an output file ( done )
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
void MatrixAddKernel ( int  *Md, int *Nd, int *Pd, int Width ){
	
	//due to row-major ordering of matrix elements
	//int Pvalue = 0;
	for ( int ty = 0; ty < Width; ++ty ){
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ ty * Width + k ];
		Pd[ ty * Width + k ] = Mdelement + Ndelement;
	}
	}
	//Pd[ ty * Width + tx  ] = Pvalue;	
}

/*
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
} */							
//END of kernel addition


//START of kernel multiplication
void MatrixMultiplication( int *Md, int *Nd, int *Pd, int Width)
{
	for (int i = 0; i < Width; ++i)
		for (int j = 0; j < Width; ++j) {
			int sum = 0;
			for (int k = 0; k < Width; ++k) {
				int a = Md[i * Width + k];
				int b = Nd[k * Width + j];
				sum += a * b;
			}
			Pd[i * Width + j] = sum;
		}
}
/*__global__ void MatrixMulKernel ( int  *Md, int *Nd, int *Pd, int Width ){
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
*/

/*
END of KERNEL functions
*/


//Start of function to write Matrix to a text file
void writeMatFile( char *filename, int *matrix, int Width ) {
	FILE *fp;
	fp = fopen( filename, "w" );
	//print dummy file data headers for now
	fprintf( fp, "0 0");
	int x = 0;
	while( x < Width * Width ){
		fprintf( fp, " %d", matrix[ x ] );
		x++;		
	}
	fclose( fp );
//	printf( "\nMatrix was successfully written to filename: %s\n", filename );
}

//Start of function to print matrix
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
void MatrixMul( char *filename0, char *filename1, char *filename2, int Width, char *Cnext ){
	int size = Width * Width * sizeof( int );
	int *Md, *Nd, *Od, *Pd, *Qd;
	char outFile[ 20 ];

//	dim3 dimBlock( Width, Width );
//	dim3 dimGrid( 1, 1 );

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
	
//	cudaMalloc( ( void** ) &Md, size );//spikVec
//	cudaMemcpy( Md, matA, size, cudaMemcpyHostToDevice );

//	cudaMalloc( ( void** ) &Nd, size );//spikTransMat
//        cudaMemcpy( Nd, matB, size, cudaMemcpyHostToDevice );

	//Ck = spikVec * spikTransMat
//	cudaMalloc( ( void** ) &Pd, size );	

//	cudaMalloc( ( void** ) &Od, size );//confVec	

//        cudaMemcpy( Od, matD, size, cudaMemcpyHostToDevice );
	
	// final matrix: Ck+1 = confVec + Ck
//	cudaMalloc( ( void** ) &Qd, size );
	
	// Ck = spikVec * spikTransMat => Pd = Md * Nd
//	MatrixMulKernel<<< dimGrid, dimBlock >>>( Md, Nd, Pd, Width );
	MatrixMultiplication( matA, matB, matC, Width);

//	cudaMemcpy( matE, Qd, size, cudaMemcpyDeviceToHost );
	printf( " \n%s * %s : \n", filename1, filename2 );
	printMatrix( matC, Width, Width );

	// Ck+1 = confVec + Ck => Qd = Od + Pd
//	MatrixAddKernel<<< dimGrid, dimBlock >>>( Od, Pd, Qd, Width );
	MatrixAddKernel( matD, matC, matE, Width );

//	cudaMemcpy( matE, Qd, size, cudaMemcpyDeviceToHost );
	printf( " \n%s + %s * %s : \n", filename0, filename1, filename2 );
	printMatrix( matE, Width, Width );

	writeMatFile( Cnext, matE, Width );

	free( matA ); free( matB ); free( matC ); free( matD ); free( matE );
//	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd ); cudaFree( Od ); cudaFree( Qd );
}
//End of Matrix multiplication function MatrixMul


/***
****END of AUXILIARY functions
****/




/***
****START of MAIN function
****/
int main ( int argc, char *argv[ ] ) {
	if ( argc < 6 ){
		printf( "\n Format: %s configurationVector spikingVector spikingTransitionMatrix squareMatrixWidth\n", argv[ 0 ] );
		exit( 1 );
	}
	char *confVec = argv[ 1 ];
	char *spikVec = argv[ 2 ];
	char *spikTransMat = argv[ 3 ];
	int width = atoi( argv[ 4 ] );
	char *Cnext = argv[ 5 ];
		
	if( ( strlen( confVec ) ) > 20 && ( strlen( spikVec ) ) > 20 && ( strlen( spikTransMat ) ) > 20  ) {
					printf( " Filename/s was/were too long ( > 20 char )  " );
					// TODO: Do something about segmentation fault here when input filename is > 20 chars
					//spikVec = { "\0" }; // doesn't work
					//*confVec = NULL; // doesn't work
	}
	else {
	//				printf( " You entered the file %s for the spiking vector \n", spikVec );
	//				printf( " You entered the file %s for the configuration vector \n", confVec );
	//				printf( " You entered the file %s for the spiking transition matrix \n ", spikTransMat );
		
	//				printf( "\nYou have entered files %s, %s, and %s and square matrix width %d \n", spikVec, confVec, spikTransMat, width );

					//load matrices from files
					FILE *ptr1 = fopen( confVec, "r" );
					FILE *ptr2 = fopen( spikVec, "r" );
					FILE *ptr3 = fopen( spikTransMat, "r" );

					if ( ptr1 == 0 && ptr2 == 0 && ptr3 == 0 ) {
						printf( "\n could not open one of the following files: %s %s %s \n", spikVec, confVec, spikTransMat );
						//should return something here
					}
					else {
						MatrixMul( confVec, spikVec, spikTransMat, width, Cnext );
					}
					fclose( ptr1 ); fclose( ptr2 ); fclose( ptr3 );
	}
}
/***
****END of MAIN function
***/

