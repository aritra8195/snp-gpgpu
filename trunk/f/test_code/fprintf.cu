#include <stdio.h>

int main ( int argc, char *argv[ ] ) {
	int arr[ 6 ] = { 0, 1, 2, 3, 5, 8 };	
	char *filename = argv[ 1 ];
	FILE *fp;
	fp = fopen( filename, "w" );
	int x = 0;
	while( x < 6 ) {
		fprintf( fp, " %d ", arr[ x ] );
		x++;
	}
	printf( "\n File %s was created and written with data \n\n", filename );
}
