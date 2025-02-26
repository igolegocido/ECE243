#define AUDIO_BASE			0xFF203040
int main(void) {
    // Audio port structure 

struct audio_t {
	volatile unsigned int control;  // The control/status register
	volatile unsigned char rarc;	// the 8 bit RARC register
	volatile unsigned char ralc;	// the 8 bit RALC register
	volatile unsigned char wsrc;	// the 8 bit WSRC register
	volatile unsigned char wslc;	// the 8 bit WSLC register
    volatile unsigned int ldata;	// the 32 bit (really 24) left data register
	volatile unsigned int rdata;	// the 32 bit (really 24) right data register
};

/* we don't need to 'reserve memory' for this, it is already there
     so we just need a pointer to this structure  */

struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
//struct audio_t *const old = ((struct audio_t *) AUDIO_BASE);

    // to hold values of samples
    int left, right;
	int pleft[3200] = {0};
	int pright[3200] = {0};
	//delay
	int N = 0;
	
	// infinite loop checking the RARC to see if there is at least a single
	// entry in the input fifos.   If there is, just copy it over to the output fifo.
	// The timing of the input fifo controls the timing of the output

    while (1) {
        
        if(audiop->rarc > 0) // check RARC to see if there is data to read
        {

	    // Did not check if output FIFO has space - we know it does,
	    // because the rate is the same as the input .
	    //  but should really have check if (audiop->wsrc > 0) - i.e. that there is an empty output FIFO slot
	    // available.  You'll need to do that in part 3. 
		left = audiop->ldata + pleft[N]*0.3;
		right = audiop->rdata + pright[N]*0.3;
			
		pleft[N] = left;
		pright[N] = right;
			
		if(N < 3200){
			N++;
		}else{
			N = 0;
		}

	    audiop->ldata = left;  // store to the left output fifo
	    audiop->rdata = right;  // store to the right output fifo
        }
    }
}