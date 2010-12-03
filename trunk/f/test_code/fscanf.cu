#include <stdio.h>

int main ( int argc, char *argv[ ] ) {
	int x, y, *z;

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
			y = 1;
			//int w = 0;
			fscanf( ptr, "%d", &x  );
			while( !feof( ptr ) ){
				if ( y < 3 ){
					fscanf( ptr, "%d", &x );
					printf( "\n A: y: %d MatEl: %d \n", y, x );
				}
				else {
					printf( "\n B: y: %d MatEl: %d ", y, x );
					fscanf( ptr, "%d", &z[ y - 3 ]  );
					printf( " z[ w ]: %d \n", z[ y - 3 ] );
					//w++;
					//z[ y - 3 ] = x;
				}
				y++;
			}
		}
	fclose( ptr );
	}
}
