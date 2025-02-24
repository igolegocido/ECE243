#define AUDIO_BASE 0xFF203040
int main(void) {
    // Audio codec Register address
    volatile int *audio_ptr = (int *) AUDIO_BASE;
	volatile int *sw_ptr = 0xFF200040;

    // intermediate values
    int left, right, fifospace, count, period, switches;
	period = 4;
	count = 0;
	
	// This is an infinite loop checking the RARC to see if there is at least a single
	// entry in the input fifos.   If there is, just copy it over to the output fifo.
	// The timing of the input fifo controls the timing of the output

    while (1) {
		//Switches part
		switches = *sw_ptr;
		if((switches & 0b1000000000) > 0)
			period = 80;
		else if((switches & 0b0100000000) > 0)
			period = 72;
		else if((switches & 0b0010000000) > 0)
			period = 64;
		else if((switches & 0b0001000000) > 0)
			period = 56;
		else if((switches & 0b0000100000) > 0)
			period = 48;
		else if((switches & 0b0000010000) > 0)
			period = 40;
		else if((switches & 0b0000001000) > 0)
			period = 32;
		else if((switches & 0b000000100) > 0)
			period = 24;
		else if((switches & 0b000000010) > 0)
			period = 16;
		else if((switches & 0b000000001) > 0)
			period = 8;
		else
			period = 4;
		
		//Audio part
        fifospace = *(audio_ptr + 1); // read the audio port fifospace register
        if (((fifospace & 0xFF000000) > 0) & ((fifospace & 0x00FF0000) > 0)) // check WSLC and WSRC to ensure they are free
        {
			if(count < (period/2)){
				left = 0;
				right = 0;
			}else{
				left = 0xFFFFFF;
				right = 0xFFFFFF;
			}
			
			// store both of those samples to output channels
			*(audio_ptr + 2) = left;
			*(audio_ptr + 3) = right;
			if(count >= period - 1)
				count = 0;
			else
				count++;
		}
    }
}
