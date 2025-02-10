.global _start
_start:

	.equ LEDs,  0xFF200000
	.equ TIMER, 0xFF202000
	.equ PUSH_BUTTON, 0xFF200050
	
	
	/*Enable Interrupts in the NIOS V processor, and set up the address handling
	location to be the interrupt_handler subroutine*/
	
	#Turn off interrupts in case an interrupt is called before correct set up
	csrw mstatus, zero 


	#activate interrupts from IRQ18 (Pushbuttons)

	li t0, 0x50000
	csrs mie, t0 

	#Set the mtvec register to be the interrupt_handler location

	la t2, interrupt_handler
	csrw mtvec, t2
	
	#Initialize the stack pointer

	li sp, 0x20000
	
	jal    CONFIG_TIMER        # configure the Timer
    jal    CONFIG_KEYS         # configure the KEYs port

	
	#Now that everything is set, turn on Interrupts in the mstatus register

	li t0, 0b1000
	csrs mstatus, t0 
	
	la t0, COUNTER_DELAY
	li t1, 1000000
	sw t1, (t0)
	
	la s0, LEDs
	la s1, COUNT
	
	LOOP:
		lw     s2, 0(s1)          # Get current count
		sw     s2, 0(s0)          # Store count in LEDs
	j      LOOP




interrupt_handler:
	#Code not shown
	addi sp, sp, -12
	
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	
	li s0, 0x7FFFFFFF  
	csrr s1, mcause
	
	and s1, s1, s0
	li  s0, 18
	beq s1, s0, KEY
	li  s0, 16
	beq s1, s0, TIME
	j end_interrupt

KEY:
	jal KEY_ISR # If so call KEY_ISR
	j end_interrupt
TIME:
	jal TIMER_ISR
	j end_interrupt
	
	end_interrupt:

	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	
	addi sp, sp, 12
	

mret

CONFIG_TIMER: 

	#Code not shown
	
	addi sp, sp, -16
	sw ra, (sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	
	la t1, TIMER
	sw zero, (t1)
	lw t2, COUNTER_DELAY
	sw t2, 0x8(t1) # store to timer start value register (low)
 	srli t2, t2, 16 # shift t0 right by 16 bits to get the upper 16b
 	sw t2, 0xc(t1) # store to timer start value register (high)
	li t0, 0b0111
	sw t0, 4(t1)
	sw zero, (t1)
	

	lw ra, (sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	addi sp, sp, 16

ret

CONFIG_KEYS: 

	#Code not shown
	addi sp, sp, -12
	sw ra, (sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	
	la t1, PUSH_BUTTON
	li t0, 0b1111
	sw t0, 8(t1)
	sw t0, 12(t1)
	
	lw ra, (sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	addi sp, sp, 12


ret

KEY_ISR: 

	addi sp, sp, -16
	sw ra, (sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	
	la t0, PUSH_BUTTON
	lw t1, 12(t0)
	li t2, 0b0001
	beq t1, t2, toggle
	li t2, 0b0010
	beq t1, t2, double
	li t2, 0b0100
	beq t1, t2, half
	j key_return
toggle:
	la t0, RUN
	lw t1, (t0)
	beqz t1, goONE
	sw zero, (t0)
	j key_return
goONE:
	li t1, 1
	sw t1, (t0)
	j key_return
double:
 	la t0, COUNTER_DELAY
	lw t1, (t0)
	li t2, 100000000000
	bge t1, t2, key_return
	slli t1, t1, 1
	sw t1, (t0)
	jal    CONFIG_TIMER 
	j key_return
half:
	la t0, COUNTER_DELAY
	lw t1, (t0)
	li t2, 100
	ble t1, t2, key_return
	srli t1, t1, 1
	sw t1, (t0)
	jal    CONFIG_TIMER 
key_return:	

	la t0, PUSH_BUTTON
	li t1, 0b1111
	sw t1, 12(t0)
	lw ra, (sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	addi sp, sp, 16

ret


TIMER_ISR:
	addi sp, sp, -16
	sw ra, (sp)
	sw t0, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	
	la t0, COUNT
	lw t1, (t0)
	lw t2, RUN
	add t1, t1, t2
	sw t1, (t0)
	la t0, TIMER
	sw zero, (t0)
	
	sw ra, (sp)
	lw t0, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	addi sp, sp, 16



ret


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.global COUNTER_DELAY
COUNTER_DELAY: .word 1000000

.end
