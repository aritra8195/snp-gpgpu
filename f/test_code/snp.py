import sys

#TODOs:
#load confVec c0 (Ck+1 several times), spikVec s0 (Sk+1 several times), spikTransMat M (once), and rules r (once)
#fConfVec = open( 

###
#START of aux functions
###

#START of function to import vectors/matrices from file/s
def importVec( filename ) :
	filePtr = open( filename, 'rb' )
	Vec = filePtr.read( )
	return Vec.split( )
#END of function to import vectors/matrices from file/s	

###
#END of aux functions
###



###
#START of Main Program Flow
###
if ( len( sys.argv ) < 5 ) :
	print '\n Program usage:\n'+sys.argv[ 0 ] + ' confVec spikVec spikTransMat rules\n'

else :
	confVec = importVec( sys.argv[ 1 ] )
	spikVec = importVec( sys.argv[ 2 ] )
	spikTransMat  = importVec( sys.argv[ 3 ] )
	rules = importVec( sys.argv[ 4 ] )
	#print ' \nconfVec:\n' + confVec +'\nspikVec:\n'+spikVec+'\nspikTransMat:\n'+spikTransMat+'\nrules:\n'+rules #works
	#for elem in confVec[ 2: ] : # the 2: is so that the loop starts @ index 2
	#x = 1	
	#print 'Neuron %d' % ( x )	
	#for rule in rules : #for loop works
	#	if rule == '$' :
	#		x += 1
	#		print ' Neuron %d' % ( x )
	#	else :
	#		print rule #works

###
#END of Main Program Flow
###

