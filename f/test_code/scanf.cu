#include <stdio.h>

int main ( void ) {
	int x;
	while( x != 3) {
	printf( "\n Type \n 1 to enter filename \n 2 for 2 \n 3 to quit \n: " );
	scanf( "%d", &x );
	switch( x ){
		case 1:
			char *str;
			printf( " Please enter filename: \n" );
			scanf( "%s", str );
			printf( " You entered the filename %s ", str );
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
