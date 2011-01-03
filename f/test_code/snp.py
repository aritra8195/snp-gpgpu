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

#START of function
def getNeurNum( confVec ) :
	cnt = 0
#	print confVec[ 2: ]
	for conf in confVec[ 2: ] :
		if conf != '0' :
			#print conf
			cnt = cnt + 1
	return cnt
#END of function

#START of function
def genSpikVec( confVec, rules  ) :
	y = 1
	for conf in confVec[ 2: ] : #run through each neuron's configuration, cross-checking them w/ their own rules
		for rule in rules :
			if rule == conf :
				print ' Neuron %d can use rule ' % ( y )  #assumes total ordering of rules
			elif rule == '$' :
				break
		#if not ruleDone :
		#	break
		y += 1

#END of function

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
	#first, determine number of neurons
	neurNum = getNeurNum( confVec )
	print ' Number of neurons is %d ' % ( neurNum )

	#see if spikes in Neuron1 confVec match a rule criteria in Neuron1 rules
	#genSpikVec( confVec, rules )
	#goal is to create [ [spike, rule1 criteria1, rule1 criteria2, ...], ... ]
	spikRuleList = [ ]
	y = 0	
	z = 1
	w = 0
	print spikRuleList
	for conf in confVec[ 2 : 2 + neurNum ] :
		spikRuleList.append( [ conf ] ) #append first conf for first neuron
		for rule in rules[ w: ] :
			if rule == '$' :
				w += 1
				break
			else :
				#print z
				spikRuleList[ y ].append( rule ) #append rules to neuron's spike in the list
				print spikRuleList
			w += 1
		if conf == '0' :
			break
		y += 1
	print ' Final \n'
	print spikRuleList

	v = 1
	for neuron in spikRuleList :
		print ' Neuron %d ' % ( v ) + ' rules \n'
		for rule in neuron[ 1: ] :
			print rule
		v += 1	

###
#END of MAIN Program Flow
###

