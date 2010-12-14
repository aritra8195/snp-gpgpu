#include <stdio.h>

int main ( void ) {
	int x;
	while( x != 3) {
		printf( "\n Type \n 1 to enter filenames < 20 in length \n 2 for 2 \n 3 to quit \n: " );
		scanf( "%d", &x );
		switch( x ){
			case 1:
				char spikVec[ 20 ], confVec[ 20 ], spikTransMat[ 20 ];

				printf( " Please enter spiking vector file: \n" );
				scanf( " %s", &spikVec );
				printf( " Please enter configuration vector file: \n" );
				scanf( " %s", &confVec );
				printf( " Please enter spiking transition matrix file: \n" );
				scanf( " %s", &spikTransMat ); 
				if( ( strlen( spikVec ) ) > 20 && ( strlen( confVec ) ) > 20 && ( strlen( spikTransMat ) ) > 20  ) {
					printf( " Filename/s was/were too long ( > 20 char )  " );
					// Do something about segmentation fault here
					//spikVec = { "\0" }; // doesn't work
					//*confVec = NULL; // doesn't work 
				}
				else {
					printf( " You entered the file %s for the spiking vector \n", spikVec );
					printf( " You entered the file %s for the configuration vector \n", confVec );
					printf( " You entered the file %s for the spiking transition matrix \n ", spikTransMat );
				}
				break;
			case 2: 
				printf( " You entered 2 \n" );
				break;
			case 3: 
				printf( " You entered quit. Bye! \n" );
				break;
			default:
				printf( " You entered an invalid choice \n" );
				break;
		}

	}
}
