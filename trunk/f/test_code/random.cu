/*
Steven Billington
January 17, 2003
exDice.cpp
Program rolls two dice with random
results.
*/
/*
Header: iostream
Reason: Input/Output stream
Header: stdlib
Reason: For functions rand and srand
Header: time.h
Reason: For function time, and for data type time_t
*/
#include <stdio.h>
#include <time.h>
/*
These constants define our upper
and our lower bounds. The random numbers
will always be between 1 and 6, inclusive.
*/
const int LOW = 1;
const int HIGH = 100;
int main()
{
/*
Variables to hold random values
for the first and the second die on
each roll.
*/
int first_die, sec_die;
/*
Declare variable to hold seconds on clock.
*/
time_t seconds;
/*
Get value from system clock and
place in seconds variable.
*/
time(&seconds);
/*
Convert seconds to a unsigned
integer.
*/
srand((unsigned int) seconds);
/*
Get first and second random numbers.
*/
first_die = rand() % (HIGH - LOW + 1) + LOW;
sec_die = rand() % (HIGH - LOW + 1) + LOW;
/*
Output first roll results.
*/
printf( "Your roll is %d, %d \n", first_die, sec_die );
//cout<< "Your roll is (" << first_die << ", "
//<< sec_die << "}" << endl << endl;
/*
Get two new random values.
*/
first_die = rand() % (HIGH - LOW + 1) + LOW;
sec_die = rand() % (HIGH - LOW + 1) + LOW;
/*
Output second roll results.
*/
printf( "My roll is %d, %d \n", first_die, sec_die );
//cout<< "My roll is (" << first_die << ", "
//<< sec_die << "}" << endl << endl;
return 0;
}

/*#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
 
int randomize( int maxIntVal ){
//	int x;
	time_t seconds;
	time( &seconds );
	srand( ( unsigned int ) seconds );
//	int max = atoi( argv[ 1 ] );
	return rand( ) % maxIntVal + 1;	
}


int main( int argc, char *argv[ ] )
{
	if ( argc != 2 )
		printf( "\nUsage:\n %s maxrandomvalue\n", argv[ 0 ] );
	else {	
		int max = atoi( argv[ 1 ] );
		int x, randNum;
		for ( x = 0; x < 50; x++ ){
			randNum = randomize( max );
			printf( "%i ", randNum );
		}
	}
}
*/
/*
# random numbers in a range
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
 
void main()
{
int x ;
srand((unsigned)time(NULL));

for(x=0;x<=100;x++)
printf("%i\t",rand()%10 + 1);

}
*/
