import sys
import os
import math
import numpy as np
from numpy import *
from pycuda import driver, compiler, gpuarray, tools
import pycuda.autoinit
import re

#
#TODOs:
# - load ONLY 1 type of rule file (for the more general reg exp)
# - Refactor code to include STUB functions/s to collect smaller functions. Separate functions into a different file.
# - Check spike debt/negative values in Ck.
#NOTES:
# - load confVec c0 (Ck+1 afterwards), spikVec s0 (Simulator determines this/these!),
# spikTransMat M (once), and rules r (once)
# - Whenever both types are usable, spiking rules are preferred over forgetting rules
# - Loops over vector and matrix lists start at index 2 (1st two indices have the dimensions of the Msnp, Can+should do something about this)
#
#CUDA C kernels evaluate:
# (1)	CK = Ck-1 + Sk-1 * Msnp
#
 
########################
#START of AUX functions#
########################
 
#START of CUDA C kernels
matmul_kernel_temp = """
 __global__ void MatrixMulKernel(int *a, int *b, int *c)
 {
  int tx = threadIdx.x;
  int ty = threadIdx.y;
 
 int Pvalue = 0;
 for (int k = 0; k < %(MATRIX_SIZE)s; ++k) {
 int Aelement = a[ty * %(MATRIX_SIZE)s + k];
  int Belement = b[k * %(MATRIX_SIZE)s + tx];
 Pvalue += Aelement * Belement;
 }
  c[ty * %(MATRIX_SIZE)s + tx] = Pvalue;
 }
"""

matadd_kernel_temp = """
__global__ void MatrixAddKernel ( int  *Md, int *Nd, int *Pd ){
    int ty = threadIdx.y;
    for ( int k = 0; k < %(MATRIX_SIZE)s; ++k ){
            int Mdelement = Md[ ty * %(MATRIX_SIZE)s + k ];
            int Ndelement = Nd[ ty * %(MATRIX_SIZE)s + k ];
            Pd[ ty * %(MATRIX_SIZE)s + k ] = Mdelement + Ndelement;
    }
} 
 """
#END of CUDA C kernels
########################################################################
#START of function to import rules from file/s
def importRule( filename ) :
	filePtr = open( filename, 'rb' )
	rer = filePtr.read( )
	rer = rer[ :-1 ].split( '&' )
	lst = [ ]
	for neuron in rer:
		lst.append( neuron.split( '@' ) )
	return lst #returns [['aa 1 1', 'aa 2 1'], ['a 1 1'], ['a 1 1', 'a 1 0']] 
#END of function to import rules from file/s	
########################################################################
#START of Function to check if number of spikes satisfy reg exp:
def chkRegExp( regexp, spikNum ) :
	spik = 'a' * spikNum #create the necessary amount of spikes
	return bool( re.search( regexp, spik ) ) #returns true if spik is in L( E )
#END of Function to check if number of spikes satisfy reg exp
########################################################################
#START
def NDarrToFile( Ck, Ck_1gpu ) :
		#write ND array into a file
		outfile = open( Ck, "w" )
		outfile.write( '$ $' )
		for row in Ck_1gpu.get( ) :
			for elem in row :
				outfile.write( ' ' + str( elem ) )
		outfile.close( )		
#END
########################################################################
#START of function
def toNumpyArr( filename, sqrMatWidth ) :
	#print ' Function: toNumpyArr'
	#print 'sqrMatWidth = ', sqrMatWidth
	#print 'filename = ', filename
	#remove extraneous 1st 2 integers in the vector's/matrix' contents, then loads the remaining ints as a numpy
	#array, then reshapes the 1D array to a square matrix
	print fromfile( filename, sep=' ', dtype=int32 )[ 2: ].reshape( sqrMatWidth, sqrMatWidth )
	return fromfile( filename, sep=' ', dtype=int32 )[ 2: ].reshape( sqrMatWidth, sqrMatWidth )
	#returns a file of the form 
	#array([[-1,  1,  1,  0,  0],
	#   [-2,  1,  1,  0,  0],
	#   [ 1, -1,  1,  0,  0],
	#   [ 0,  0, -1,  0,  0],
	#   [ 0,  0, -2,  0,  0]], dtype=int32)
#END of function
########################################################################
#START of function to import vectors/matrices from file/s
def importVec( filename ) :
	filePtr = open( filename, 'rb' )
	Vec = filePtr.read( )
	return Vec.split( )
#END of function to import vectors/matrices from file/s	
########################################################################
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
########################################################################
#START of function
	#output: list of list of form [ [spike/s, rule1 criterion1, rule1 criterion2, ...], ... ]
	#e.g. [['1', '2', '2'], ['0', '1'], ['9', '1', '2']]
def genSpikRuleList( confVec, neurNum, rules, ruleregexp ) :
#	ruleregexp = [['aa 1 1', 'aa 2 1'], ['a 1 1'], ['a 1 1', 'aa 1 0']]
	#print ' Function genSpikRuleList'
	#print 'rules ', rules
	spikRuleList = [ ]
	for spike in confVec[ 2: 2 + neurNum ] :
		spikRuleList.append( spike )
	print 'spikRuleList ',spikRuleList
	return spikRuleList
#END of function
########################################################################
#START of function
	#function to print neurons + rules criterion and total order
def prNeurons( spikeRuleList ) :
	v = w = 1
	for neuron in spikRuleList :
		#print ' \nNeuron %d ' % ( v ) + ' rules criterion/criteria and total order '
		for rule in neuron[ 1: ] :
			#print ' (%d) ' % ( w ) + rule
			w += 1
		v += 1	
#END of function
########################################################################
#START of function 
def genPotentialSpikrule( spikRuleList, neurNum, ruleregexp ) :
	#generate a list of spikes + rules they are applicable to via, in order
	#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
	#input spikRuleList = [['2', '2', '2'], ['1', '1'], ['1', '1', '2']] and
	#ruleregexp = [['aa 1 1', 'aa 2 1'], ['a 1 1'], ['a 1 1', 'aa 1 0']]
	#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  
	tmpList = [ ]
	for neuron in ruleregexp : #produces list of list similar to spikRuleList, but empty
		tmp = [ [ ' ' ] * ( len( neuron) + 1 ) ]
		tmpList.append( tmp[ 0 ] )
	print tmpList
	x = sameCnt = 0
	y = 1
	for idx, spike in enumerate( spikRuleList ) :
		spike = neuron
		#print spike
		for idx2, rule in enumerate( neuron[ 1: ] ) :
			#print int( rule ) + spike
			# currently the SRS for rules of type 1) for now...
			regexp = ruleregexp[ idx ][ idx2 ]
			regexp = regexp.split( )
			#print 'regexp = ', regexp
			#check more general regular expressions
			if chkRegExp( regexp[ 0 ], int( spike ) ) :
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
########################################################################
#START of function
def genNeurSpikVecStr( tmpList, neurNum ) :
	# generate all possible + valid 10 strings PER neuron
	# if tmp = [ '01', '10 ], tmp2 = [ '1' ], returns tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
	x = 0
	tmp3 = [ ]
	# loop over total number of neurons ( x )
	while x < neurNum :
		y = 1 
		#get the max number of elements of tmpList that satisfy the SRS criterion
		tmp4 = [ ]
		# loop over total number of rules ( y )
		#print 'x', x
		if max( tmpList[ x ][ 1: ] ) == 0 :
			maxConfSpikMatch = 1 
		else :
			 maxConfSpikMatch = max( tmpList[ x ][ 1: ] )
		
		while y <= maxConfSpikMatch :
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
			#print '\t\t FCN spikstr =', spikStr
			tmp4[ y - 1: ] = [ spikStr ]
			#print '\t\t', tmp4
			# builds nested list: tmp = [ '01', '10 ] tmp2 = [ '1' ] then tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]	
			#print '\tB' #works
			y += 1 	
		tmp3[ x: ] = [ tmp4 ]	
		x += 1
		#print tmp3tmp = [ '01', '10 ] tmp2 = [ '1' ] then tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
	return tmp3
#END of function
########################################################################
#START of function
	#pair up sub-lists in tmpList to generate a single list of all possible + valid 10 strings
def genNeurPairs( tmpList ) :	
	#print 'tmpList = ', tmpList
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
		#print '\ttmp5, x ', tmp5, x
	#delete excess/unnecessary lists generated from above, retain only the last generated list
	del tmp5[ : -1 ]
	#print 'tmp5 ', tmp5
	return tmp5
#END of function
########################################################################
#START of function
def createSpikVecFiles( spikTransMat, allValidSpikVec ) :
	#write all valid spiking vectors onto each of their own files e.g. given 10110, create file s_10110 and write 10110 in it
	fileStrLen = len( spikTransMat )
	#print ' length of spikTransMat is ', fileStrLen
	for spikVec in  allValidSpikVec[ 0 ] :
		x =  0
		spikVecFile = 's_' + spikVec 
		outfile = open( spikVecFile, "w" )
		#create function to turn spikVec e.g. 10110 to a format 'understood' by C CUDA program, padded w/ 0s 
		#and 1 white space apart. Total length of file must be same as spikTransMat (the matrix file)
		outfile.write( spikTransMat[ 0 ] + ' ' + spikTransMat[ 1 ] )
		for spik in  spikVec  :
			outfile.write( ' ' + spik )
		
		while x < fileStrLen - len( spikVec ) - 2 :
			#print '\t', x
			outfile.write( ' ' + '0' )
			x += 1
		#outfile.write( spikVec )
		outfile.close( )
		#print spikVecFile + ' file written into ' 
#END of function
########################################################################
#START of function
def createConfVecFiles( spikTransMat, Ck_vec ) :
#write the Ck string onto a file in the same format as the input matrix file
# TODO: create a list of lists to add info whether a given Ck file has been created already (Done, but using an external text file)
	#print 'Function: createConfVecFiles' 
	fileStrLen = len( spikTransMat )
	#print ' length of spikTransMat is ', fileStrLen
	#print ' Ck_vec = ', Ck_vec
	for Ck in  Ck_vec :
		x =  0
		confVecFile = 'c_' + Ck 
		outfile = open( confVecFile, "w" )
		#create function to turn confVec e.g. 211 to a format 'understood' by C CUDA kernel, padded w/ 0s 
		#and 1 white space apart. Total length of file must be same as spikTransMat (the matrix file)
		outfile.write( spikTransMat[ 0 ] + ' ' + spikTransMat[ 1 ] )
		CkLen = 0
		for C in  Ck  :
			if C != '-' :
				outfile.write( ' ' + C )
				CkLen += 1
		#print ' CkLen ', CkLen
		
		while x < fileStrLen - CkLen -2  :
			#print '\tx ', x
			outfile.write( ' ' + '0' )
			x += 1
		#outfile.write( spikVec )
		outfile.close( )
		#print confVecFile + ' file written into ' 
#END of function
########################################################################
#START of function
def concatConfVec( lst ):
	#print 'Function concatConfVec'
	index = 3
	confVec = ''
	#append first Ck element/spike before concatenating dashes
	confVec += str( lst[ 2 ] )
	while index <= neurNum + 1 :
		confVec += '-' + str( lst[ index ] )
		#print confVec
		index += 1
	return confVec
#END of function
########################################################################
#START of function
def genCks( allValidSpikVec, MATRIX_SIZE, configVec_str, spikTransMatFile) :
	#using all generated valid spiking vector files, 'feed' the files to the CUDA C kernels to evaluate (1)
	for spikVec in  allValidSpikVec[ 0 ] :
		# string concatenation of the configVec, Ck-1, from configVec = [ '2', '2', '1', '0', '0', ...]
		# to configVec = 211 <string>
		Ck_1_str = configVec_str 
		#write into total list of Ckspri
		#allGenCk = addTotalCk( allGenCk, Ck_1_str )
		#print spikVec		
		#form the filenames of the Cks and the Sks
		Ck = 'c_' + Ck_1_str + '_' + spikVec
		Ck_1 = 'c_' + Ck_1_str
		Sk = 's_' + spikVec
		#print ' Ck, Ck_1, Sk: ', Ck, Ck_1, Sk
		#import the vectors/Matrix as numpy ND arrays 
		Ck_1 = toNumpyArr( Ck_1, MATRIX_SIZE )
		Sk = toNumpyArr( Sk, MATRIX_SIZE )
		M = toNumpyArr( spikTransMatFile, MATRIX_SIZE )
		#allocate memory in the GPU
		Ck_1gpu = gpuarray.to_gpu( Ck_1 )
		Skgpu = gpuarray.to_gpu( Sk )
		Mgpu = gpuarray.to_gpu( M )
		SkMgpu = gpuarray.empty( ( MATRIX_SIZE, MATRIX_SIZE), np.int32 )
		Ckgpu = gpuarray.empty( ( MATRIX_SIZE, MATRIX_SIZE), np.int32 )
		#get kernel code from template by specifying the constant MATRIX_SIZE
		matmul_kernel = matmul_kernel_temp % { 'MATRIX_SIZE': MATRIX_SIZE}
		matadd_kernel = matadd_kernel_temp % { 'MATRIX_SIZE': MATRIX_SIZE}
		# compile the kernel code 
		mulmod = compiler.SourceModule(matmul_kernel)
		addmod = compiler.SourceModule(matadd_kernel)
		matrixmul = mulmod.get_function( "MatrixMulKernel" )
		matrixadd = addmod.get_function( "MatrixAddKernel" )
		#call kernel functions
		matrixmul( Skgpu, Mgpu, SkMgpu, block = (MATRIX_SIZE, MATRIX_SIZE, 1), )
		matrixadd( Ck_1gpu, SkMgpu, Ckgpu, block = ( MATRIX_SIZE, MATRIX_SIZE, 1 ), )
		#print Ck_1gpu.get()[ 4 ] #this is a numpy ND array
		#write ND array into a file
		NDarrToFile( Ck, Ckgpu )
#END of function
########################################################################
#START of function
#add a Ck <type 'str'> into total list of generated Cks + write it into file \n separated
def addTotalCk( allGenCk, Ck_1_str ) :
	if Ck_1_str in allGenCk :
		return allGenCk
	else :
#		Ck_1_str = Ck_1_str.replace( '-', '')
		allGenCk += [ Ck_1_str ]
		totalCkFile = open( allGenCkFile, 'a' )
		totalCkFile.write( Ck_1_str + '\n' )
		totalCkFile.close( )
		print 'Ck ', Ck_1_str, 'was written into file', allGenCkFile
		return allGenCk
#END of function
########################################################################
#START of function
#works for strings 
def isConfVecZero( Ck ) :
	for x in Ck :
		if x != '-' :
			if int( x ) != 0 :
				return False
	return True
#END of function
########################################################################
#START of function
def printMatrix( spikTransMat ) :
#takes as input a matrix in row-major format of <type 'list'> and prints the matrix 'nicely'
	#get dimensions of matrix
	matRows = int( spikTransMat[ 0 ] )
	matCols = int( spikTransMat[ 1 ] )
	x = 0
	while x < matRows :
		y = 2
		matRowElms = ' '
		while y < matCols :
			matRowElms += spikTransMat[ x * matCols + y ] + ' '
			y += 1
		#print matRowElms
		x += 1
#END of function

######################
#END of AUX functions#
######################



############################
#START of MAIN Program Flow#
############################

#Check if correct number of cl args are entered
if ( len( sys.argv ) < 5 ) :
	print '\n Program usage:\n'+sys.argv[ 0 ] + ' confVec spikTransMat rules rules-in-reg-exp\n'

#if correct, proceed
else :
	confVecFile = sys.argv[ 1 ]
	spikTransMatFile = sys.argv[ 2 ]
	rulesFile = sys.argv[ 3 ]
	ruleRegExpFile = sys.argv[ 4 ]

#####
#{1}#	Input Ck (C0 initially), spiking transition matrix, rules
#####	
	confVec = importVec( confVecFile )
	#spikVec = importVec( sys.argv[ 2 ] )
	spikTransMat  = importVec( spikTransMatFile )
	rules = importVec( rulesFile )
	ruleregexp = importRule( ruleRegExpFile )

	#first, determine number of neurons
	print ' ruleregexp', ruleregexp
	neurNum = len( ruleregexp )

	#preliminary prints
	print '\n' + '*'*50 + 'SNP system simulation run STARTS here' + '*'*50 + '\n'
	print '\nSpiking transition Matrix: '
	#printMatrix( spikTransMat )
	print '\nSpiking transition Matrix in row-major order (converted into a square matrix):\n', spikTransMat[ 2: ]
	#print '\nRules of the form a^n/a^m -> a or a^n ->a loaded:\n', rules
	print '\nInitial configuration vector:\n', confVec, '\nor in dash delimited format:', concatConfVec( confVec )


#####
#{2}#	proceed to determining spikVec from loaded rules + confVec, then invoke CUDA C code
#####	works for rules of type 3) only for now

	print '\nNumber of neurons for the SN P system is %d ' % ( neurNum )
	
	#generate list of list of form [ [spike/s, rule1 criterion1, rule1 criterion2, ...], ... ]
	spikRuleList = genSpikRuleList( confVec, neurNum, rules, ruleregexp )
	print 'genSpikRuleList(): spikeRuleList =',spikRuleList
	
	#function to print neurons + rules criterion and total order
	#prNeurons( spikRuleList )
	#print '\n'

	#generate a list of spikes + rules they are applicable to, in order
	#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
	#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  
	tmpList = genPotentialSpikrule( spikRuleList, neurNum, ruleregexp )
	print 'genPotentialSpikrule(): tmpList = ', tmpList
	
	# generate all possible + valid 10 strings PER neuron
	# if tmp = [ '01', '10 ], tmp2 = [ '1' ], returns tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
	tmpList = genNeurSpikVecStr( tmpList, neurNum )
	print 'genNeurSpikVecStr(): tmpList = ', tmpList

	#pair up sub-lists in tmpList to generate a single list of all possible + valid 10 strings
	allValidSpikVec = genNeurPairs( tmpList )
	print 'genNeurPairs(): allValidSpikVec =', allValidSpikVec

	#create total (not global) list of all generated Ck + Sk to prevent loops in the computation tree +extra file creation
	allGenCk = [ ]
	allGenSk = [ ]	
	allGenCkFile = "allGenCkFile.txt"
	#create allGenCkFile file w/o writing anything into it for now
	totalCkFile = open( allGenCkFile, 'w' )
	totalCkFile.close( )

	# string concatenation of the configVec, Ck-1, from configVec = [ '2', '2', '1', '0', '0', ...]
	# to configVec = 211 <type 'str'>
	print 'len of confVec + confVec', len( confVec ), confVec
	Ck_1_str = concatConfVec( confVec ) 
	#write into total list of Cks
	allGenCk = addTotalCk( allGenCk, Ck_1_str )


	#write all valid spiking vectors onto each of their own files e.g. given 10110, create file s_10110 and write 10110 in it
	createSpikVecFiles( spikTransMat, allValidSpikVec )

	#print confVec
	print ' spikTransMat len ', len( spikTransMat )
	sqrMatWidth = int( math.sqrt( len( spikTransMat ) ) )

#####
#{3}#	using all generated valid spiking vector files, 'feed' the files to the CUDA C kernel to evaluate (1)
#####	

	#write all valid config vectors onto each of their own files e.g. given 211, create file c_211 and write 211 in it
	createConfVecFiles( spikTransMat, allGenCk )
	
	#use PyCUDA to evaluate equation (1) in parallel
	genCks( allValidSpikVec, sqrMatWidth, concatConfVec( confVec ),  spikTransMatFile )

	#add all Cks generated from C0
	for spikVec in allValidSpikVec[ 0 ] :
	#build filename string for the the Ck to be loaded from file
		strn = 'c_' +  concatConfVec( confVec ) + '_' + spikVec
		#import/load Cks generated by Ck-1 from files
		C_k_vec = importVec( strn )
		C_k = concatConfVec( C_k_vec )
		#add the generated Ck-1 to the total list of generated Cks
		addTotalCk( allGenCk, C_k )

	print ' allGenCk =', allGenCk
	print ' End of C0 \n**\n**\n**'

#####
#{4}#	From {3}, exhaustively repeat steps {1} to {3} on all generated Ck/c_xxxx except C0
#####
	#print isVecZero( [ '0', '0', '0', '0','0','1','0','0' ] )
	#Ck = confVec
	print ' initial total Ck list is allGenCk =', allGenCk
	#exhaustively loop through total Ck list/list of all the generated Ck except C0

	allGenCkFilePtr = open( allGenCkFile, 'rb' )
#	Ck = allGenCkFilePtr.readline( )	
	Ck = allGenCkFilePtr.readline( )	
	strlen = len( Ck.replace( '-', '') )
	CkCnt = 0
	while (Ck != '') :
#	while (Ck != '') & ( CkCnt != 20 ) :
		print 'Current spikVec:', spikVec, ' and Ck:', Ck
		#for Cks whose string length exceeds the number of neurons e.g. neurons = 3 Ck = 2110 (2,1,10)
		Ck = Ck.replace( '\n', '' )

		#no more spikes to be used by the P system
		if isConfVecZero( Ck ) : #works
			print '\tZero Ck/spikes. Stop.'
			print '\n' + '*'*50 + 'SNP system simulation run ENDS here' + '*'*50 + '\n'
			allGenCkFilePtr.close( )
			break
		else :
			#write all valid config vectors onto each of their own files e.g. given 211, create file c_211 and write 211 in it
			#print ' allGenCk ', allGenCk
			createConfVecFiles( spikTransMat, allGenCk )

			#build filename string for the Ck to be loaded from file
			strn = 'c_' +  Ck
			#import/load Cks generated by Ck-1 from files
			C_k_vec = importVec( strn )
			C_k = concatConfVec( C_k_vec )

			#generate list of list of form [ [spike/s, rule1 criterion1, rule1 criterion2, ...], ... ]
			spikRuleList = genSpikRuleList( C_k_vec, neurNum, rules, ruleregexp )
			#print '\tList of lists w/ spike + rule criterion, spikRuleList = ', spikRuleList, ' for Ck = ', C_k

			#generate a list of spikes + rules they are applicable to, in order
			#e.g. C0 = 2 1 1, r = 2 2 $ 1 $ 1 2
			#output should be : [['2', 1, 2], ['1', 1], ['1', 1, 0]]  
			tmpList = genPotentialSpikrule( spikRuleList, neurNum, ruleregexp )
			#print '\tAfter generating list of spikes+rules, tmpList = ', tmpList

			# generate all possible + valid 10 strings PER neuron
			# if tmp = [ '01', '10 ], tmp2 = [ '1' ], returns tmp = [ tmp, tmp2 ] to get tmp = [ [ '01', '10 ], [ '1' ] ]
			tmpList = genNeurSpikVecStr( tmpList, neurNum )
			#print '\tAfter generating all valid+possible spik vecs, tmpList =', tmpList

			#pair up sub-lists in tmpList to generate a single list of all possible + valid 10 strings
			allValidSpikVec = genNeurPairs( tmpList )
			print '\tAll valid 10 strings i.e. spiking vectors are in allValidSpikVec =', allValidSpikVec

			#write all valid spiking vectors onto each of their own files e.g. given 10110, create file s_10110 and write 10110 in it
			createSpikVecFiles( spikTransMat, allValidSpikVec )

			#print confVec
			sqrMatWidth = int( math.sqrt( len( spikTransMat ) ) )

			#write all valid config vectors onto each of their own files e.g. given 211, create file c_211 and write 211 in it
			#print ' All currently generated config vectors/Cks are allGenCk = ', allGenCk
			createConfVecFiles( spikTransMat, allGenCk )

			#print 'allValidSpikVec, sqrMatWidth, Ck, spikTransMatFile ' , allValidSpikVec, sqrMatWidth, Ck, spikTransMatFile
			genCks( allValidSpikVec, sqrMatWidth, Ck, spikTransMatFile)

			#add all Cks generated from C0
			for spikVec in allValidSpikVec[ 0 ] :
			#build filename string for the the Ck to be loaded from file
				strn = 'c_' +  Ck + '_' + spikVec
				#import/load Cks generated by Ck-1 from files
				C_k_vec = importVec( strn )
				C_k = concatConfVec( C_k_vec )
				#print '\t\tLoaded file ', strn, ' and concatenated its contents into to C_k ', C_k
				#add the generated Ck-1 to the total list of generated Cks
				addTotalCk( allGenCk, C_k )

			print '\t\tGenerated from Sk-1 = ', spikVec, 'and Ck-1 =', Ck, 'is Ck = ', C_k
			addTotalCk( allGenCk, C_k )

			print '\tAll generated Cks are allGenCk =', allGenCk	
			print '\n**\n**\n**'		

			#go read the next Ck in the file allGenCkFile = "allGenCkFile.txt"	
			Ck = allGenCkFilePtr.readline( )		
			CkCnt += 1
	print '\nNo more Cks to use (infinite loop/s otherwise). Stop.\n' + '\n' + '*'*50 + 'SNP system simulation run ENDS here' + '*'*50 + '\n'
##########################
#END of MAIN Program Flow#
##########################
