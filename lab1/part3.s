.global _start
_start:	li		s1,	0  		#s1 = where result is stored initialize to 0
		li		s0, 30		#s0 = 30 largest number to add
	
loop:	add 	s1, s1, s0	#add s0 to the sum of all numbers before it
		addi 	s0, s0, -1	#decrease s0 by 1
		beqz 	s0, done	#check if s0 is 0 to send code into inf loop
	
		j loop
	
done: j done