int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
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

