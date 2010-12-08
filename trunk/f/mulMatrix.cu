#include <stdio.h>
//#include <cuda.h>
//#include "cuda_runtime_api.h"
//#include <stdint.h>
//#include <stdlib.h>

//#define Width 4

/*
** START of auxiliary functions
*/

//Matrix multiplication kernel function
__global__ void MatrixMulKernel ( int  *Md, int *Nd, int *Pd, int Width ){
	//2D thread ID
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	//Pvalue stores Pd element computed by thread
	int Pvalue = 0;
	for ( int k = 0; k < Width; ++k ){
		int Mdelement = Md[ ty * Width + k ];
		int Ndelement = Nd[ k * Width + tx ];
		Pvalue += Mdelement * Ndelement;
	}

	//Write matrix to device memory; each thread writes one element
	Pd[ ty * Width + tx  ] = Pvalue;
}// End of Matrix multiplication kernel function

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

//Matrix multiplication function
// assumes a SQUARE matrix for now
void MatrixMul( int *M, int *N, int *P, int Width ){
	int size = Width * Width * sizeof( int );
	int *Md, *Nd, *Pd;

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
/*
	//Print matrix P
	for ( int w = 0; w < Width * Width; w++ ){
		printf( "\n" );
		printf( " %d: %d  ", w, P[w] );
		printf( "\n" );
	}

	printMatrix( P, 4, 4 ); */

	//Free device matrices
	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd );
}//End of MatrixMul function	

//Start of getMatWidth => Get width i.e. # of columns
int getMatWidth( char *filename ){
	int width;
	//assumes space separate integer values e.g. -1 23 4 -56 6 77
	//assumes first integer in file is row, 2nd integer is column
	FILE *ptr = fopen( filename, "r" );
	if ( ptr == 0 ){
		printf( "\n could not open file %s \n", filename );
		width = 0;
	}
	else{
		fscanf( ptr, "%d", &width  );
	}
	fclose( ptr );
	return width;
}//end of getMatWidth function

//Start of getMatHeight => Get height i.e. # of rows
int getMatHeight( char *filename ){
	int height, dummy;
	//assumes space separate integer values e.g. -1 23 4 -56 6 77
	//assumes first integer in file is row, 2nd integer is column
	FILE *ptr = fopen( filename, "r" );
	if ( ptr == 0 ){
		printf( "\n could not open file %s \n", filename );
		height = 0;
	}
	else{
		for ( int count = 1; count < 3; count++ ){
			if ( count != 2 )
				fscanf( ptr, "%d", &dummy );
			else
				fscanf( ptr, "%d", &dummy  );
				height = dummy;
		}
	}
	fclose( ptr );
	return height;
}//end of getMatHeight function

//START of loadMatrixFile function
void loadMatrixFile( char *filename, int *array, int cols, int rows ) {
	//assumes space separate integer values e.g. -1 23 4 -56 6 77
	int x, y, *dummy;
	FILE *matFile = fopen( filename, "r" );
	if ( matFile == 0 ){
		printf( "\n could not open file %s \n", filename );
	}
	else{
		y = 1;
		int offset = 4;
		//z = 0;
		fscanf( matFile, "%d", &x );
		while( !feof( matFile ) && y <  rows * cols + offset ) {
			if ( y < offset ){
				fscanf( matFile, "%d", &x );
				printf( " A: y = %d x = %d \n ", y, x );
			}
			else {
				fscanf( matFile, "%d", &dummy[ y - offset ] );
				//fscanf( matFile, "%d", &x );
				//printf( " B: y = %d x = %d \n", y, x );
				printf( " B: y = %d dummy[ z ] = %d \n", y, dummy[ y - offset ] );
				//z++;
				//array[ y - offset ] = x;
			}
			y++;
		} 
	}
	fclose( matFile ); 
	//return array; 
}//END of loadMatrixFile function

/*
** END OF Auxiliary functions
*/


/*
** START OF MAIN FUNCTION
*/

int main ( int argc, char *argv[ ] ) {
	int Width = 4;
	
	//populate arrays to multiply
	int A[ Width * Width ];

	for ( int x = 0; x < Width * Width; x++ ){
		A[ x ] = 1;
	}
	
	int B[ Width * Width ];
	for ( int z = 0; z < Width * Width; z++ ){
		B[ z ] = 2;
	}
	
	int C[ Width * Width ];
	
	char *filename1 = argv[ 1 ];
	char *filename2 = argv[ 2 ];
	int *matA; //holds first matrix
	int *matB; //holds sencond matrix

	if ( argc != 3 ) /* argc should be 4 for correct execution */ {
		/* We print argv[0] assuming it is the program name */
		printf( "\nusage: %s matrixFile1 matrixFile2 \n\n", argv [0 ] );
	}
	else {

		//returns # of cols of matrix, zero otherwise
		int matWidthA = getMatWidth ( filename1  );
		//get # of rows of matrix, zero otherwise
		int matHeightA = getMatHeight( filename1 );

		//returns # of cols of matrix, zero otherwise
		int matWidthB = getMatWidth ( filename2  );
		//get # of rows of matrix, zero otherwise
		int matHeightB = getMatHeight( filename2 );
		
		//load matrices from files
		loadMatrixFile( filename1, matA, matWidthA, matHeightA );
		//loadMatrixFile( filename2, matB );

        //Print matrix P
	        for ( int w = 0; w < matWidthA * matWidthA; w++ ){
		        printf( "\n" );
			printf( " %d: %d  ", w, matA[ w ] );
			printf( "\n" );
		}
		//printMatrix( matA, matWidthA, matHeightA );

		//printf( " widht of matrix A: %d \n ", matWidthA );
		//printf( "height of matrix A: %d \n\n", matHeightA );
	}
	//MatrixMul( A, B, C, Width );
}
/*
** END OF MAIN FUNCTION
*/
