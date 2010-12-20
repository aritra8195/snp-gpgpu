#include <stdio.h>
#include <ctype.h>

int main ( int argc, char *argv[ ] ){
	if ( argc != 2 )
		printf( "\n Usage \n%s filetoread \n", argv[ 0 ] );
	else {
		char x; 
		int rules[ 100 ]; //length of rules that can be read
		int a = 0;
		char *filename = argv[ 1 ];
		FILE *ptr1 = fopen( filename, "r" );
		fscanf( ptr1, "%c", &x  );
		while( !feof( ptr1 ) ) {
			if ( isalnum( x ) ) {
				int y = atoi( &x );
				//printf( "\n%d", y );
				fscanf( ptr1, "%c", &x );
				rules[ a ] = y;
			}
			else { // ! = 33, $ = 36, ' ' = 32
				//printf( "-ELSE-" );
				rules[ a ] = -1;
				fscanf( ptr1, "%c", &x );
			}
			a++;
		}
	//print the loaded rules
	// Rules on file: 2 2 $ 1 $ 1 2
	// Rules on load: |2 |-1 |2 |-1 |-1 |-1 |1 |-1 |-1 |-1 |1 |-1 |2 |-1 |
		printf( "\n" );
		int oneCnt = 1;
		int ruleCnt = 1;
		int neuron = 1;
		// Find out how many rules are there.
		for( int x = 0; rules[ x ] != 0; x++) {
			//printf( "%d |", rules[ x ] );
			if ( rules[ x ] > 0 && oneCnt < 4 ){
				oneCnt = 1;
			}
			else if ( rules[ x ] < 0 && oneCnt < 3 ) {
				oneCnt = oneCnt + 1;
			}
			else if ( rules[ x ] < 0 && oneCnt == 3 ) {
				oneCnt = 1;
				ruleCnt = ruleCnt + 1;
			}
		}
		oneCnt = 1;
		printf( "\nThere are %d rules loaded\n", ruleCnt );
		int rulePrint = 1;
		printf( "Neuron %d rule/s:\n", neuron );
		for( int x = 0; rulePrint <= ruleCnt && rules[ x ] != 0; x++) {
			//printf( "%d |", rules[ x ] );
			if ( rules[ x ] > 0 && oneCnt < 4 ){
				printf( " %d ", rules[ x ], oneCnt, rulePrint );
				oneCnt = 1;
			}
			else if ( rules[ x ] < 0 && oneCnt < 3 ) {
				oneCnt = oneCnt + 1;
//				printf( " B " );
			}
			else if ( rules[ x ] < 0 && oneCnt == 3 ) {
				neuron = neuron + 1;
				printf( "\nNeuron %d rule/s:\n", neuron );
				oneCnt = 1;
				rulePrint = rulePrint + 1;
//				printf( " C " );
			}
		} 
	//	printf( " '%c' '%d' '%c' '%d' '%c' '%d'", " ", " ", "$", "$", 33, 33 );
		printf( "\n" );
	}	
}
