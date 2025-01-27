/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	lw t0, InputWord
	li t1, 0
	

loop:
	beq t0, zero, return
	andi t2, t0, 1
	add t1, t1, t2
	srli t0, t0, 1
	j loop
	
return:
	la t0, Answer
	sw t2, (t0)
stop: j stop

.data
InputWord: .word 0x4a01fead

Answer: .word 0