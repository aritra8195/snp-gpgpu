import sys

#TODOs:
#load confVec c0 (Ck+1 several times), spikVec s0 (Program must determine this!),
# spikTransMat M (once), and rules r (once)

###
#START of AUX functions
###

#START of function to import vectors/matrices from file/s
def importVec( filename ) :
	filePtr = open( filename, 'rb' )
	Vec = filePtr.read( )
	return Vec.split( )
#END of function to import vectors/matrices from file/s	

###
#END of AUX functions
###



###
#START of MAIN Program Flow
###

#Check if correct number of cl args are entered
if ( len( sys.argv ) < 4 ) :
	print '\n Program usage:\n'+sys.argv[ 0 ] + ' confVec spikTransMat rules\n'

#if correct, proceed
else :
	confVec = importVec( sys.argv[ 1 ] )
	#spikVec = importVec( sys.argv[ 2 ] )
	spikTransMat  = importVec( sys.argv[ 2 ] )
	rules = importVec( sys.argv[ 3 ] )
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

#proceed to determining spikVec from loaded rules + confVec, then invoke CUDA C code
	#see if spikes in Neuron1 confVec match a rule criteria in Neuron1 rules
	y = 1
	#print 'test'
	#for conf in confVec[ 2: ] : #run through each neuron's configuration, cross-checking them w/ their own rules
	for idx, rule in enumerate( rules ) :
		if rule == '$' :
			print 'iff'
			continue #stop current loop and go to next neuron and its rules
		elif rule == '2' :
			print ' Neuron %d can use rule %d' % ( y, idx )  #assumes total ordering of rules
	#y += 1

###
#END of MAIN Program Flow
###

