int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    line_bounce();
}
void line_bounce(){
	volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	int y = 0;
	_Bool up = 1;
	*(pixel_ctrl_ptr +1) = *(pixel_ctrl_ptr);
	int status = *(pixel_ctrl_ptr +3);
	while(1){
		wait_for_vsync();
		if(y == 240){
			up = 0;
		}else if(y == 0){
			up = 1;
		}
		draw_line(0,y,319,y,0x0000);
		if(up){
			y++;
		}else{
			y--;
		}
		draw_line(0,y,319,y,0xffff);
		*(pixel_ctrl_ptr) = 1;
		
	}
}
void wait_for_vsync()
{
	volatile int * pixel_ctrl_ptr = (int *) 0xff203030; // base address
	int status;
	*pixel_ctrl_ptr = 1; // start the synchronization process
	// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) // polling loop waiting for S bit to go to 0
		{
		status = *(pixel_ctrl_ptr + 3);
	}
}

// code not shown for clear_screen() and draw_line() subroutines
void clear_screen(){
	for(int i =0;i<320;i++){
		for(int j=0;j< 240;j++){
			plot_pixel(i,j,0x0000);
		}
	}
}

void draw_line(int x_1, int y_1, int x_2, int y_2, short int line_color)
{
	_Bool is_steep = abs(y_2 - y_1) > abs(x_2 - x_1);
	if(is_steep){
		int temp = x_1;
		x_1 = y_1;
		y_1= temp;
		
		temp = x_2;
		x_2 = y_2;
		y_2 = temp;
	}
	if(x_1 > x_2){
		int temp = x_1;
		x_1 = x_2;
		x_2 = temp;
		
		temp = y_1;
		y_1 = y_2;
		y_2 = temp;
	}
	
	int deltax = x_2 - x_1;
	int deltay = abs(y_2-y_1);
	int error  = -(deltax/2);
	int y = y_1;
	int y_step = -1;
	if(y_1<y_2) y_step = 1;
	for(int i = x_1;i<=x_2;i++){
		if(is_steep){
			plot_pixel(y, i, line_color);
		}else {
			plot_pixel(i, y, line_color);
		}
		error = error + deltay;
		if(error > 0){
			y = y + y_step;
			error = error - deltax;
		}
	}
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);

        *one_pixel_address = line_color;
}

