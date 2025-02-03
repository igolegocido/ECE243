.global _start
	.equ KEY_BASE, 0xFF200050
	.equ LEDs, 0xFF200000 
	.equ COUNTER, 0xFF202000
	.equ COUNTER_DELAY, 100000000
_start:
			la t0, KEY_BASE
			la t1, LEDs
			la t6, COUNTER
			sw zero, 0(t6) 
			li t2, COUNTER_DELAY
			sw t2, 0x8(t6) # store to timer start value register (low)
 			srli t2, t2, 16 # shift t0 right by 16 bits to get the upper 16b
 			sw t2, 0xc(t6) # store to timer start value register (high)
			
			li t2, 0b0110 # bits to enable continuous mode and start timer
 			sw t2, 4(t6) 
			
			li t2, 0
			li t3, 255
			li t5, 15
			la sp, 0x20000
loop:
			sw t2, (t1)
			lw t4, 0xC(t0)
			andi t4, t4, 15
			bnez t4, pause
			addi t2, t2, 1
			bge t2, t3, reset
			j ploop
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
			
			

ploop: 	lw s0, (t6) # read the timer status register, i
 		andi s0, s0, 0b1 # mask everything but the TO bit (bit 0)
		beqz s0, ploop # if TO bit is 0, keep checking it!
 		sw zero, (t6) # clear the TO bit 
		j loop

.data
COUNTER_DELAY: .word 500000