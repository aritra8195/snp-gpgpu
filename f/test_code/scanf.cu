#include <stdio.h>

int main ( void ) {
	int x;
	while( x != 3) {
	printf( " Type \n 1 for 1 \n 2 for 2 \n 3 to quit \n: " );
	scanf( "%d", &x );
	switch( x ){
		case 1:
			printf( " You entered 1 \n" );
			break;
                case 2: 
                        printf( " You entered 2 \n" );
                        break;
                case 3: 
                        printf( " You entered quit. Bye! \n" );
                        break;
		default:
			printf( " You entered an invalid choice " );
			break;
	}
	}
}
