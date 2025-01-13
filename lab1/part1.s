.global _start
_start:
	
 li t0, 2 /* t0 <- 2 */
 li t1, 3 /* t1 <- 3 */
 
 add s0, t0, t1 /* s0 <- t0 + t1 */
 
 done: j done
