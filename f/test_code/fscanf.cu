#include <stdio.h>

int main ( int argc, char *argv[ ] ) {
	int x;

    	if ( argc != 2 ) /* argc should be 4 for correct execution */
    	{
		/* We print argv[0] assuming it is the program name */
		printf( "\nusage: %s filenametoread \n\n", argv[0] );
	}
	else
	{	//assumes space separate integer values e.g. -1 23 4 -56 6 77
		FILE *ptr = fopen( argv[ 1 ], "r" );
		if ( ptr == 0 )
			printf( "\n could not open file %s \n", argv[ 1 ] );
		else
		{
			fscanf( ptr, "%d", &x  );
			while( !feof( ptr ) ){
				printf( "\n %d \n", x );
				fscanf( ptr, "%d", &x );
			}
		}
	fclose( ptr );
	}
}
