/*
#include <iostream>
#include <cstdlib>
#include <time.h>

//upper and lower bounds, inclusive
const int LOW = 1;
const int HIGH = 6;
int main()
{
int first_die, sec_die;

//Declare variable to hold seconds on clock.

time_t seconds;

//Get value from system clock and place in seconds variable.

time(&seconds);

// Convert seconds to a unsigned int

srand((unsigned int) seconds);
first_die = rand() % (HIGH - LOW + 1) + LOW;
sec_die = rand() % (HIGH - LOW + 1) + LOW;
printf( "Your roll is %d, %d \n", first_die, sec_die );
return 0;
}
*/
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

/*
// random numbers in a range
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
 
int main( void )
{
int x ;
srand((unsigned)time(NULL));

for(x=0;x<=100;x++)
printf("%i\t",rand()%99 + 1);

}
*/
