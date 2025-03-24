#include <stdlib.h>
volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	int N = 8;
	int x_box[N], y_box[N], colour_box[N], dx_box[N], dy_box[N];
	int x_back[N], y_back[N];
	int colour[4] = { 0xffff, 0xf800, 0x07e0, 0x001f  } ;

	for(int i =0;i<N;i++){
		x_box[i] = rand()%318;
		y_box[i] = rand()%238;
		x_back[i] = x_box[i];
		y_back[i] = y_box[i];
		colour_box[i] = colour[rand() % 4];
		dx_box[i] = (( rand() %2) *2) - 1;
		dy_box[i] = (( rand() %2) *2) - 1; 
		
	}
	

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
		
		//clear_screen();
		for(int i =0;i<N;i++){
			
			draw_box(x_back[i], y_back[i], 0x0000);
			if(i!=7){
				draw_line(x_back[i], y_back[i], x_back[i+1], y_back[i+1], 0x0000);
			}
			if(i==0){
				draw_line(x_back[i], y_back[i], x_back[7], y_back[7], 0x0000);
			}
		}

        // code for drawing the boxes and lines (not shown)
		for(int i =0;i<N;i++){
			
			x_back[i] = x_box[i];
			y_back[i] = y_box[i];
			
			if(x_box[i] == 318){
				dx_box[i] = -1;
			}
			else if(x_box[i] == 0){
				dx_box[i] = 1;
			}
			if(y_box[i] == 238){
				dy_box[i] = -1;
			} else if(y_box[i] == 0){
				dy_box[i] = 1;
			}
			x_box[i] += dx_box[i];
			y_box[i] += dy_box[i];
			
		}
		for(int i =0;i<N;i++){
			
			draw_box(x_box[i], y_box[i], colour_box[i]);
			if(i!=7){
				draw_line(x_box[i], y_box[i], x_box[i+1], y_box[i+1], 0xffff);
			}
			if(i==0){
				draw_line(x_box[i], y_box[i], x_box[7], y_box[7], 0xffff);
			}
			
			 // code for updating the locations of boxes (not shown)
			
			
		}
       

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)
void draw_box(int x, int y, short int colour){
	for(int i =0;i<2;i++){
		for(int j =0;j<2;j++){
			plot_pixel(x+i, y+j, colour);
		}
	}
}
void wait_for_vsync()
{
	volatile int * pixel_ctrl_ptr = (int *) 0xff203020; // base address
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

