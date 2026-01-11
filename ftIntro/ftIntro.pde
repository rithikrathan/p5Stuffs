// -=-=-=-=-=-=-=-=[Some global varialbles here]=-=-=-=-=-=-=-=-

// objects
ArrayList<complex> Xk = new ArrayList<complex>();

// vars
float time;
float dt;


public class complex {
	float re;
	float im;
	float Phase;
	float Frequency;
	float Amplitude;

	// complex number w = x + iy
	complex(float x, float y){
		this.re = x;
		this.im = y;
	}

	void add(complex b){
		this.re += b.re;
		this.im += b.im;
	}

	void multiply(complex b) {
			float tempRe = this.re; 
			this.re = (tempRe * b.re) - (this.im * b.im);
			this.im = (tempRe * b.im) + (b.re * this.im);
	}
}

// -=-=-=-=-=-=-=-=[Processing Sketch]=-=-=-=-=-=-=-=-
void setup(){
	frameRate(60);

	size(600,600);
	scale(1,-1);

	time  = 0;

	float[] x = { 
	  100,  50,   0, -50, 
	 -100, -100, -100, -100, 
	 -100, -50,   0,  50, 
	  100,  100,  100,  100 
	};

	float[] y = { 
	  100,  100,  100,  100, 
	  100,  50,   0, -50, 
	 -100, -100, -100, -100, 
	 -100, -50,   0,  50 
	};
	ArrayList<complex> Xn = new ArrayList<complex>();

	for (int i = 0; i < x.length; i++) {
		Xn.add(new complex(x[i], y[i]));
	}

	Xk = dft(Xn);
	// sorting from large epicircles to small epicircles
	Xk.sort((a, b) -> Float.compare(b.Amplitude, a.Amplitude));
	// sorting from high frequency epicircles to low frequency epicircles
	// Xk.sort((a, b) -> Float.compare(b.Frequency, a.Frequency));
	dt = TAU / Xk.size();
		
	int count = 0;
	for (complex epicircle : Xk) {
		println("---EPICIRCLE" + count + "---");
		println("RealComponent: " + epicircle.re);
		println("ImaginaryComponent" + epicircle.im);
		println("Amplitude(radius)" + epicircle.Amplitude);
		println("Phase(angle)" + epicircle.Phase);
		println("Frequency" + epicircle.Frequency);
		count++;
	}
}


void drawEpicycles(float x, float y, float scale, float time, ArrayList<complex> Xk){
	// variables to track the position of the current epicycle
	float prevX = x;  
	float prevY = y;  

	for (complex epicycle : Xk) {
		if (epicycle.Frequency < Xk.size()) {
			float currX = prevX + epicycle.Amplitude * scale * cos(epicycle.Frequency * time + epicycle.Phase);
			float currY = prevY + epicycle.Amplitude * scale * sin(epicycle.Frequency * time + epicycle.Phase);

			stroke(255,255,255);
			// strokeWeight(4);
			// point(x, y);
			strokeWeight(1);
			line(prevX,prevY, currX, currY);
			noFill();
			circle(prevX, prevY, epicycle.Amplitude * 2);
			// strokeWeight(9);
			// point(currX,currY);
			prevX = currX;
			prevY = currY;
		}
	}

	stroke(255,0,0);
	strokeWeight(9);
	point(prevX, prevY);
}

void draw(){
	translate(300,300);
	background(10,10,30);
	// do everything here every frame 

	drawEpicycles(0,0,(float)1,time,Xk);

	// dont do anything related to the  the epicycle things after this
	// print(dt);
	time += dt * 0.05;
}








