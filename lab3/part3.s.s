/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	la sp, 0x20000
	la t0, TEST_NUM
loop1:
	
	call ONES
		
return:
	la t0, Answer
	sw a0, (t0)
	

stop: j stop

ONES:
	addi sp, sp, -12
	sw ra, (sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
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
	lw t1, 4(sp)
	lw t2, 4(sp)
	addi sp, sp, 12
	ret


.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0