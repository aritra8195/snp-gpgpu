#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
 
int main( int argc, char *argv[ ] )
{
	if ( argc != 2 )
		printf( "\nUsage:\n %s maxrandomvalue\n", argv[ 0 ] );
	else {	
		int x;
		srand( ( unsigned ) time( NULL ) );
		int max = atoi( argv[ 1 ] );
		for(x=0;x<=50;x++)
		printf("%i\t", rand() % max + 1 );

		printf( "\n" );
	}
}
