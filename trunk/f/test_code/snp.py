#import os

#load confVec c0 (Ck+1 several times), spikVec s0 (Sk+1 several times), spikTransMat M (once), and rules r (once)

#fConfVec = open( 
import sys

def importVec( filename ) :
	filePtr = open( filename, 'rb' )
	return filePtr.read( )
	

#print sys.argv[ 3 ]
#for arg in sys.argv: 
#    print arg
if ( len( sys.argv ) < 5 ) :
	print '\n Program usage:\n'+sys.argv[ 0 ] + ' confVec spikVec spikTransMat rules\n'

else :
	confVec = sys.argv[ 1 ]
	spikVec = sys.argv[ 2 ]
	spikTransMat  = sys.argv[ 3 ]
	rules = sys.argv[ 4 ]
	print ' \nConfiguration vector is:\n' + importVec( confVec ) #works

