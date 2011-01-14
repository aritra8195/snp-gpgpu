import sys

#TODOs:
#load confVec c0 (Ck+1 several times), spikVec s0 (Program must determine this!),
# spikTransMat M (once), and rules r (once)
# works for rules of type 3) only for now
#create function to implement the spike-rule selection (SRS) criterion
#QUESTION: how to implement
# 1) a( aa )+ ( a bit more elaborate reg ex)
# 2) a^2/a -> a	(reg ex not equal to spikes consumed)
# 3) a^2 -> a ???

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

#START of function
	#generate list of list of form [ [spike/s, rule1 criterion1, rule1 criterion2, ...], ... ]
def genSpikRuleList( confVec, rules ) :
	spikRuleList = [ ]
	y = 0	
	z = 1
	w = 0
	#print spikRuleList
	for conf in confVec[ 2 : 2 + neurNum ] : #loop starts @ index 2
		spikRuleList.append( [ conf ] ) #append first conf for first neuron
		for rule in rules[ w: ] :
			if rule == '$' :
				w += 1
				break
			else :
				#print z
				spikRuleList[ y ].append( rule ) #append rules to neuron's spike in the list
				#print spikRuleList
			w += 1
		if conf == '0' :
			break
		y += 1
	return spikRuleList
#END of function

#START of function
	#function to print neurons + rules criterion and total order
def prNeurons( spikeRuleList ) :
	v = w = 1
	for neuron in spikRuleList :
		print ' \nNeuron %d ' % ( v ) + ' rules criterion and total order '
		for rule in neuron[ 1: ] :
			print ' (%d) ' % ( w ) + rule
			w += 1
		v += 1	

#END of function

#START of function
	#generate a list of spikes + rules they are applicable to, in order
	#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
	#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  

def genPotentialSpikrule( spikRuleList ) :
	#generate a list of spikes + rules they are applicable to via, in order
	#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
	#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  
	tmpList = spikRuleList
	#print tmpList
	x = sameCnt = 0
	y = 1
	for neuron in spikRuleList :
		spike = neuron[ 0 ]
		#print spike
		for rule in neuron[ 1: ] :
			#print int( rule ) + spike
			# currently the SRS
			if int( rule ) <= int( spike ) :
				#print ' A %d %d ' % ( x, y )
				#print tmpList
				sameCnt += 1
				tmpList[ x ][ y ] = sameCnt
			else :
				#print ' B %d %d ' % ( x, y )
				#print tmpList
				tmpList[ x ][ y ] = 0
			y += 1
		x += 1
		y = 1
		sameCnt = 0
	return tmpList

#END of function


#START of function
def genNeurSpikVecStr( tmpList, neurNum ) :
	#generate all possible + valid 10 strings per neuron	
	x = 0
	tmp3 = [ ]
	# loop over total number of neurons ( x )
	while x < neurNum :
		#print ' x = ', x #works - 
		y = 1
		#get the max number of elements of tmpList that satisfy the SRS criterion
		tmp4 = [ ]
		# loop over total number of rules ( y )
		while y <= max( tmpList[ x ][ 1: ] ) :
			#print '\ty = ', y			
			# to get index of a certain value val in list, use index() e.g. x = list.index( val )
			# replace with 1, the value of tmpList whose index is equal to y, 0 on ever other element
			# find which index has value == x
			# idx = tmpList.index( y )
			#genSpikVecStr( tmpList, y )
			z = 1
			spikStr = ''
			while z <= len( tmpList[ x ][ 1: ] ) :
				#print '\t\tz =', z #, range( len( tmpList[ x ] ) )
				#print '\t\t tmpList[ x ][ z ] =', int( tmpList[ x ][ z ] )
				if int( tmpList[ x ][ z ] ) == y :
#					print 'IF', int( tmpList[ x ][ z ] )
					spikStr = spikStr + '1'
				else :
#					print 'ELSE', int( tmpList[ x ][ z ] )
					spikStr = spikStr + '0'
				z += 1
			#print '\t\t', spikStr
			tmp4[ y - 1: ] = [ spikStr ]
			#print '\t\t', tmp4

			#create function to implement the spike-rule selection (SRS) criterion
			#QUESTION: how to implement
			# 1) a( aa )+ ( a bit more elaborate reg ex)
			# 2) a^2/a -> a	(reg ex not equal to spikes consumed)
			# 3) a^2 -> a ???

			#chkSRS (check SRS). Currently only type 3) are implemented here

			# builds nested list: tmp = [ '01', '10 ] tmp2 = [ '1' ] then tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]	

			#print '\tB' #works
			y += 1 	
		tmp3[ x: ] = [ tmp4 ]	
		x += 1
		#print tmp3tmp = [ '01', '10 ] tmp2 = [ '1' ] then tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
	return tmp3
#END of function

#START of function
	#pair up sub-lists in tmpList to generate a single list of all possible + valid 10 strings
def genNeurPairs( tmpList ) :	
	x = 0
	tmp5 = [ ]
	while x < len( tmpList ) - 1 :
		#print 'X ', x
		#print tmpList[ x ], tmpList[ x + 1 ]
		# exhaustively pair up elements of each neuron i.e. r = [ [10,01], [10,01] ] do
		# r[ 0 ][ 0 ] + r[ 1 ][ 0 ] = 1010, [ 0 ][ 0 ] + tmp[ 1 ][ 1 ] = 1001 ...
		w = y = 0
		tmp6 = [ ]
		#loop over length of first neuron
		while y < len( tmpList[ x ] ) :		
			#print '\tY', y
			z = 0
			tmp7 = [ ]
			# loop over length of 2nd neuron in the pair
			while z < len( tmpList[ x + 1 ] ) :
				#print '\t\ttmp6 BEFORE: ', tmp6
				#print '\t\tZ', z
				# place into a list all possible pairs between the 2 neurons
				tmp7 = tmpList[ x ][ y ] + tmpList[ x + 1 ][ z ]
				#print '\t\ttmp7 ', tmp7 
				
				w += 1				
				z += 1
				tmp6[ w: ] = [ tmp7 ]
				#print '\t\ttmp6 AFTER: ', tmp6
			y += 1 
			#print '\ttmp6 ', tmp6
		#insert the newly created list into the original list (tmpList), so it can be used in conjunction
		#w/ the rest of the loop
		tmpList[ x + 1 : x + 2 ] =  [ tmp6 ] 
		#print '\ttmpList inserted w/ tmp6', tmpList
		#print '\ttmp6 ', tmp6
		x += 1
		tmp5[ y: ] = [ tmp6 ]
	#delete excess/unnecessary lists generated from above, retain only the last generated list
	del tmp5[ : x - 1 ]
	#print 'tmp5 ', tmp5
	return tmp5
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

#proceed to determining spikVec from loaded rules + confVec, then invoke CUDA C code
#works for rules of type 3) only for now
	#first, determine number of neurons
	neurNum = getNeurNum( confVec )
	print ' Number of neurons is %d ' % ( neurNum )

	#see if spikes in Neuron1 confVec match a rule criterion (SRS) in Neuron1 rules
	#genSpikVec( confVec, rules )
	
	#generate list of list of form [ [spike/s, rule1 criterion1, rule1 criterion2, ...], ... ]
	spikRuleList = genSpikRuleList( confVec, rules )
	#print spikRuleList
	
	#function to print neurons + rules criterion and total order
	#prNeurons( spikRuleList )

	#generate a list of spikes + rules they are applicable to, in order
	#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
	#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  

	tmpList = genPotentialSpikrule( spikRuleList )
	#print ' tmpList = ', tmpList

	# get min/max values in a list: min( list) and max( list )
	
	# generate all possible + valid 10 strings PER neuron
	# if tmp = [ '01', '10 ], tmp2 = [ '1' ], returns tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
	tmpList = genNeurSpikVecStr( tmpList, neurNum )

	print ' tmpList = ', tmpList

	#pair up sub-lists in tmpList to generate a single list of all possible + valid 10 strings
	allValidSpikVec = genNeurPairs( tmpList )
	print ' All valid 10 strings i.e. spiking vectors are ', allValidSpikVec
	
	#write all valid spiking vectors onto each of their own files e.g. given 10110, create file c_10110 and write 10110 in it
	fileStrLen = len( spikTransMat )
	print ' length of spikTransMat is ', fileStrLen
	for spikVec in  allValidSpikVec[ 0 ] :
		x =  0
		spikVecFile = 's_' + spikVec 
		outfile = open( spikVecFile, "w" )
		#create function to turn spikVec e.g. 10110 to format 'understood' by C CUDA program, padded w/ 0s 
		#and 1 blank space apart. Total length of file must be same as spikTransMat (the matrix file)
		outfile.write( spikTransMat[ 0 ] + ' ' + spikTransMat[ 1 ] )
		for spik in  spikVec  :
			outfile.write( ' ' + spik )
		
		while x < fileStrLen - len( spikVec ) - 2 :
			#print '\t', x
			outfile.write( ' ' + '0' )
			x += 1
		#outfile.write( spikVec )
		outfile.close( )
		print spikVecFile + ' file created and written into '
#

###
#END of MAIN Program Flow
###

