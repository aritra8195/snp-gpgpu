#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
 
int randomize( int maxIntVal, int seed1 ){
//	int x;
	time_t seconds;
	time( &seconds );
	seconds += seconds + seed1;
	srand( ( unsigned int ) seconds );
//	srand( ( unsigned ) time( NULL ) );
//	srand( ( unsigned ) seed );
//	int max = atoi( argv[ 1 ] );
	return rand( ) % maxIntVal + 1;	
}


int main( int argc, char *argv[ ] )
{
	if ( argc != 2 )
		printf( "\nUsage:\n %s maxrandomvalue\n", argv[ 0 ] );
	else {	
		int randMax = atoi( argv[ 1 ] );
		int x, randNum;
		for ( x = 0; x < 50; x++ ){
			randNum = randomize( randMax, x * randMax );
			printf( "%i ", randNum );
		}
	}
}
