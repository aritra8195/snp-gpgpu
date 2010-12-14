#include <stdio.h>
//#include <cuda.h>
//#include "cuda_runtime_api.h"
//#include <stdint.h>
//#include <stdlib.h>

//This is the working matrix multiplication code - very basic
/*
Done:
Done:
- printing of matrix in a more pleasant manner using printMatrix function
- command line arguments
- opens matrix files and reads the matrix successfully
- working array passing from main to auxiliary (loadMatrixFile) function :)
- fixed printing of matrix

Problems:
- MatA and MatB values are overlapping and erroneous
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


//function to print matrix
void printMatrix ( int *M, int rows, int columns ){
	//assumes matrix is in row-major format
	int index;
	printf ( "\n \n " );
	for ( int v = 0; v < rows; v++  ){
	//assumes a square matrix
		for ( int w = 0; w < columns; w++   ) {
			index = v * columns + w;
			printf ( " [%d] %03d", index, M[ index ]  );
		}
		printf ( " \n\n " );
	}
}//End of printMatrix function


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

	printf( " C:\n" );
	for ( int w = 0; w < Width * Width; w++ ){
		printf( "\n" );
		printf( " %d: %d  ", w, P[w] );
		printf( "\n" );
	}

	//printMatrix( P, Width, Width );

	cudaFree( Md ); cudaFree( Nd ); cudaFree ( Pd );
}
//End of Matrix multiplication function


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
			printf( " B: z[ %d ]: %d \n", w, z[ w - offset ] );
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

//END of Auxiliary functions


//START of Main function
int main ( int argc, char *argv[ ] ) {
	int offset = 2;

	if ( argc != 3 ) {
		printf( "\nusage: %s matrixFile1 matrixFile2 \n\n", argv [ 0 ] );
	}
	else {
		char *filename1 = argv[ 1 ];
		char *filename2 = argv[ 2 ];
		//int *matA; //holds 1st matrix
		//int *matB; //holds 2nd matrix
		
		printf( "you have entered files %s and %s \n", filename1, filename2 );
		//load matrices from files
		FILE *ptr1 = fopen( filename1, "r" );
		FILE *ptr2 = fopen( filename2, "r" );

		if ( ptr1 == 0 && ptr2 == 0 )
			printf( "\n could not open one of the following files: %s %s \n", argv[ 1 ], argv[ 2 ] );
		else {
		//load matrices from files
			//get heigh/rows and width/columns of matrices
			int matWidthA = getMatWidth ( filename1  );
			int matHeightA = getMatHeight ( filename1  );
			
			int matWidthB = getMatWidth ( filename2  );
			int matHeightB = getMatHeight ( filename2  );
			
			int *matA = ( int * )malloc( sizeof( int ) * matWidthA );
			printf( "Width and height of Matrix A: %d %d and init values are\n", matWidthA, matWidthA );
			printMatrix( matA, matHeightA, matWidthA );
			loadMatrixFile( filename1, matA, matWidthA, matHeightA );

			printf( " \nMatrix A after loading from file: \n" );
			printMatrix( matA, matHeightA, matWidthA );
			
			int *matB = ( int * )malloc( sizeof( int ) * matWidthB );
			printf( "Width and height of Matrix B: %d %d and init values are\n", matWidthB, matWidthB );
			printMatrix( matB, matHeightB, matWidthB );
			loadMatrixFile( filename2, matB, matWidthB, matHeightB );
		
			printf( " \nMatrix A after loading from file: \n" );
			printMatrix( matA, matHeightA, matWidthA );
			
			printf( " \nMatrix B after loading from file: \n" );
			printMatrix( matB, matHeightB, matWidthB );

			//assumes a square matrix
			int *matC = ( int * )malloc( sizeof( int ) * matWidthA );
			

			printf( "A: \n" );
			for ( int w = 0; w < matWidthA * matWidthA + 10; w++ ){
			        printf( "%d: %d \n",w,  matA[ w ] );
			}
			printf( "\n B:\n" );
			for ( int v = 0; v < matWidthB * matWidthB + 10; v++ ){
			        printf( "%d: %d \n", v, matB[ v ] );
			}
			printf( "\n" );

			free( matA ); free( matB ); free( matC );
			
			printf( "A: \n" );
			for ( int w = 0; w < matWidthA * matWidthA + 10; w++ ){
			        printf( "%d: %d \n",w,  matA[ w ] );
			}
			printf( "\n B:\n" );
			for ( int v = 0; v < matWidthB * matWidthB + 10; v++ ){
			        printf( "%d: %d \n", v, matB[ v ] );
			}
			printf( "\n" );
			
			MatrixMul( matA, matB, matC, matWidthA );
			
			printf( " \nMatrix C: \n" );
			printMatrix( matC, matWidthA, matWidthA );

			free( matA ); free( matB ); free( matC );
		}
		fclose( ptr1 ); fclose( ptr2 );
	}
}
//END of Main function
