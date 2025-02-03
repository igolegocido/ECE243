.global _start
	.equ KEY_BASE, 0xFF200050
	.equ LEDs, 0xFF200000 
_start:
	la t0, KEY_BASE
	la t1, LEDs
	li t2, 1
	li t5, 15
	mv a0, t0

display:
	lw t3, (t0)
	andi t4, t3, 1
	bne t4, zero, reset
	andi t4, t3, 2
	bne t4, zero, add
	andi t4, t3, 4
	bne t4, zero, minus
	andi t4, t3, 8
	bne t4, zero, blank
	j display

reset:
	call wait
	sw t2, (t1)
	j display
	
add:
	call wait
	lw t6, (t1)
	beq t6, t5, display
	addi t6, t6, 1
	sw t6, (t1)
	j display
minus:
	call wait
	lw t6, (t1)
	beq t6, t2, display
	addi t6, t6, -1
	sw t6, (t1)
	j display
blank:
	call wait 
	sw zero, (t1)
anybutton:
	lw t3, (t0)
	andi t4, t3, 15
	bne t4, zero, reset
	j anybutton

wait:
	lw s1, (a0)
	bne s1, zero, wait
	ret
	
	