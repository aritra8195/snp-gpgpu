#include <iostream>
using namespace std;
 
 int main (){    
  
    int Matrix[4][4] = {{111,22.1,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}};
     
       for (int i=0; i<sizeof Matrix/sizeof Matrix[0]; ++i)
         {
	     for (int j=0; j<sizeof Matrix[0] /sizeof Matrix[0][0]; ++j)
	           printf("%03d ", Matrix[i][j]);
		       cout << '\n';
		         }
			 return 0;
			 }
