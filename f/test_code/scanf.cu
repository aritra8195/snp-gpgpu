#include <stdio.h>

int main ( void ) {
	int x, y;
	char *str;
	while( x != 3) {
		printf( "\n Type \n 1 to enter filename \n 2 for 2 \n 3 to quit \n: " );
		scanf( "%d", &x );
		switch( x ){
			case 1:
				y = 0;
				printf( " Please enter filename: \n" );
				scanf(" %c",&str);
				while( str[ y ] != EOF ){ 
					scanf(" %c",&str);
				}
				printf( " You entered the filename %s ", str);
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
