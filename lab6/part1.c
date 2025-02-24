int main(void)
{
	volatile int *LEDR_ptr = 0xFF200000;
	volatile int *KEYs = 0xff200050;
	int edge_cap;
	*LEDR_ptr = 0b0;
	*(KEYs + 3) = 0b1111;
 	while (1) { // infinite loop
		edge_cap = *(KEYs + 3);
		if(edge_cap & 0b0001){
			*LEDR_ptr = 0b1111111111;
			*(KEYs + 3) = 0b1111;
		}else if(edge_cap & 0b0010){
			*LEDR_ptr = 0b0;
			*(KEYs + 3) = 0b1111;
		}
	 }
} 