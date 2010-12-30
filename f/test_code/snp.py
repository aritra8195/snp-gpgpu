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
	confVec = importVec( sys.argv[ 1 ] )
	spikVec = importVec( sys.argv[ 2 ] )
	spikTransMat  = importVec( sys.argv[ 3 ] )
	rules = importVec( sys.argv[ 4 ] )
	print ' \nconfVec:\n' + confVec +'\nspikVec:\n'+spikVec+'\nspikTransMat:\n'+spikTransMat+'\nrules:\n'+rules #works
	
