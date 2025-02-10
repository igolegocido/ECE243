.global _start
_start:


.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

.equ PUSH_BUTTON, 0xFF200050

#Your code goes below here:

#Your code should:

#Turn off interrupts in case an interrupt is called before correct set up
csrw mstatus, zero 

#Initialize the stack pointer

li sp, 0x20000

#activate interrupts from IRQ18 (Pushbuttons)

li t0, 0x40000
csrs mie, t0 

#Set the mtvec register to be the interrupt_handler location

la t2, interrupt_handler
csrw mtvec, t2

/*Allow interrupts on the pushbutton's interrupt mask register, and any 
#additional set up for the pushbuttons */

la t1, PUSH_BUTTON
li t0, 0b1111
sw t0, 8(t1)
sw t0, 12(t1)

#Now that everything is set, turn on Interrupts in the mstatus register

li t0, 0b1000
csrs mstatus, t0 

IDLE: j IDLE #Infinite loop while waiting on interrupt

interrupt_handler:
	addi sp, sp, -12
	
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	
	li s0, 0x7FFFFFFF  
	csrr s1, mcause
	
	and s1, s1, s0
	li  s0,18
	bne s1, s0, end_interrupt
	
	jal KEY_ISR # If so call KEY_ISR
	
	end_interrupt:

	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	
	addi sp, sp, 12
	

mret

KEY_ISR: 

#Your KEY_ISR code here

addi sp, sp, -32
sw ra, 0(sp)
sw t0, 4(sp)
sw t1, 8(sp)
sw t2, 12(sp)
sw a0, 16(sp)
sw a1, 20(sp)
sw t3, 24(sp)
sw t4, 28(sp)

la t0, PUSH_BUTTON 
lw t1, 12(t0) 

andi t1, t1, 0b1111
li t2, 0b0001
beq t1, t2, ONE
li t2, 0b0010
beq t1, t2, TWO
li t2, 0b0100
beq t1, t2, THREE
li t2, 0b1000
beq t1, t2, FOUR

ONE:
sw t2, 12(t0)
li a0, 1
li a1, 0
la t2, HEX_BASE1
lw t3, (t2)
andi t3, t3, 0b1111111
bnez t3, clear
j disp

TWO:
sw t2, 12(t0)
li a0, 2
li a1, 1
la t2, HEX_BASE1
lw t3, (t2)
li t4, 0b1111111
slli t4, t4, 8
and t3, t3, t4
bnez t3, clear
j disp

THREE:
sw t2, 12(t0)
li a0, 3
li a1, 2
la t2, HEX_BASE1
lw t3, (t2)
li t4, 0b1111111
slli t4, t4, 12
and t3, t3, t4
bnez t3, clear
j disp

FOUR:
sw t2, 12(t0)
li a0, 4
li a1, 3
la t2, HEX_BASE1
lw t3, (t2)
li t4, 0b1111111
slli t4, t4, 24
and t3, t3, t4
bnez t3, clear
j disp

clear:
li a0, 17
disp:
call HEX_DISP

lw ra, 0(sp)
lw t0, 4(sp)
lw t1, 8(sp)
lw t2, 12(sp)
lw a0, 16(sp)
lw a1, 20(sp)
lw t3, 24(sp)
lw t4, 28(sp)
	
addi sp, sp, 32

ret

HEX_DISP:   
		addi sp, sp, -16
		sw s0,0(sp)
		sw s1,0x4(sp)
		sw s2,0x8(sp)
		sw s3,0xC(sp)
	
		la   s0, BIT_CODES         # starting address of the bit codes
	    andi     s1, a0, 0x10	       # get bit 4 of the input into r6
	    beq      s1, zero, not_blank 
	    mv      s2, zero
	    j       DO_DISP
not_blank:  andi     a0, a0, 0x0f	   # r4 is only 4-bit
            add      a0, a0, s0        # add the offset to the bit codes
            lb      s2, 0(a0)         # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			la       s0, HEX_BASE1         # load address
			li       s1,  4
			blt      a1,s1, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      a1, a1, s1            # if hex4 or hex5, we need to adjust the shift
			addi     s0, s0, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     a1, a1, 3             # hex*8 shift is needed
			addi     s3, zero, 0xff        # create bit mask so other values are not corrupted
			sll      s3, s3, a1 
			li     	 a0, -1
			xor      s3, s3, a0  
    		sll      a0, s2, a1            # shift the hex code we want to write
			lw    	 a1, 0(s0)             # read current value       
			and      a1, a1, s3            # and it with the mask to clear the target hex
			or       a1, a1, a0	           # or with the hex code
			sw    	 a1, 0(s0)		       # store back
END:			
			mv 		 a0, s2				   # put bit pattern on return register
			
			
			lw s0,0(sp)
			lw s1,0x4(sp)
			lw s2,0x8(sp)
			lw s3,0xC(sp)
			addi sp, sp, 16
			ret


.data
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			