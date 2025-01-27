/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	la sp, 0x20000
	lw a0, InputWord
	call ONES
		
return:
	la t0, Answer
	sw a0, (t0)
	

stop: j stop

ONES:
	addi sp, sp, -4
	sw ra, (sp)
	li t1, 0
loop:
	beq a0, zero, done
	andi t2, a0, 1
	add t1, t1, t2
	srli a0, a0, 1
	j loop
done:
	mv a0, t1
	lw ra, (sp)
	addi sp, sp, 4
	ret


.data
InputWord: .word 0x4a01fead

Answer: .word 0