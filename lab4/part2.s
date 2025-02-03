.global _start
	.equ KEY_BASE, 0xFF200050
	.equ LEDs, 0xFF200000 
_start:
			la t0, KEY_BASE
			la t1, LEDs
			li t2, 0
			li t3, 255
			li t5, 15
			la sp, 0x20000
loop:
			sw t2, (t1)
			lw t4, 0xC(t0)
			andi t4, t4, 15
			bnez t4, pause
			call DO_DELAY
			addi t2, t2, 1
			bge t2, t3, reset
			j loop
reset:
			li t2, 0
			j loop

pause:
		sw t5, 0xC(t0)
pauseloop:
		lw t4, 0xC(t0)
		andi t4, t4, 15
		bnez t4, next
		j pauseloop
next:
		sw t5, 0xC(t0)
		j loop
			
			

DO_DELAY: 	
			addi sp, sp, -4
			sw s0, (sp)
			la s0, COUNTER_DELAY
			lw s0, (s0)
SUB_LOOP: 	addi s0, s0,-1
 			bnez s0, SUB_LOOP
			lw s0, (sp)
			addi sp, sp, 4
			ret

.data
COUNTER_DELAY: .word 500000