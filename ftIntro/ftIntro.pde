// -=-=-=-=-=-=-=-=[ GLOBALS ]=-=-=-=-=-=-=-=-
ArrayList<complex> Xk = new ArrayList<complex>();
ArrayList<complex> Xn = new ArrayList<complex>(); // Stores the original Blue Square
ArrayList<PVector> path = new ArrayList<PVector>(); // Stores the Green Trail

float time;
float dt;
int trailLength = 50; // Determines how long the tail is
					   
public class complex {
    float re, im, Phase, Frequency, Amplitude;
    complex(float x, float y){ this.re = x; this.im = y; }
    void add(complex b){ this.re += b.re; this.im += b.im; }
    void multiply(complex b) {
        float tempRe = this.re; 
        this.re = (tempRe * b.re) - (this.im * b.im);
        this.im = (tempRe * b.im) + (b.re * this.im);
    }
}

// -=-=-=-=-=-=-=-=[ SETUP ]=-=-=-=-=-=-=-=-
void setup(){
	frameRate(60);
    size(600,600);
    time = 0;

	// A Heart Shape (50 points)
	float[] x = {
	  0.0, 0.3, 2.6, 8.5, 18.9, 34.2, 53.9, 76.5, 100.1, 122.3, 
	  141.0, 153.9, 159.8, 157.8, 148.3, 132.2, 111.5, 88.3, 64.9, 43.6, 
	  26.0, 13.1, 5.0, 1.1, 0.0, -0.0, -1.1, -5.0, -13.1, -26.0, 
	  -43.6, -64.9, -88.3, -111.5, -132.2, -148.3, -157.8, -159.8, -153.9, -141.0, 
	  -122.3, -100.1, -76.5, -53.9, -34.2, -18.9, -8.5, -2.6, -0.3, -0.0
	};

	float[] y = {
	  50.0, 53.3, 62.6, 76.2, 91.3, 105.2, 115.2, 119.2, 116.2, 106.2, 
	  90.1, 69.4, 46.1, 21.6, -2.6, -25.8, -47.9, -68.8, -88.8, -107.8, 
	  -125.7, -141.6, -154.9, -164.4, -169.4, -169.4, -164.4, -154.9, -141.6, -125.7, 
	  -107.8, -88.8, -68.8, -47.9, -25.8, -2.6, 21.6, 46.1, 69.4, 90.1, 
	  106.2, 116.2, 119.2, 115.2, 105.2, 91.3, 76.2, 62.6, 53.3, 50.0
	};    
	
	// Populate Xn (The Input)
    for (int i = 0; i < x.length; i++) {
        Xn.add(new complex(x[i], y[i]));
    }

    Xk = dft(Xn); // Calls your existing DFT function
    
    // Sort by Amplitude
    Xk.sort((a, b) -> Float.compare(b.Amplitude, a.Amplitude));

    dt = TAU / Xk.size();
}

// -=-=-=-=-=-=-=-=[ DRAW LOOP ]=-=-=-=-=-=-=-=-
void draw(){
    background(10,10,30);
    translate(300,300);
    scale(1,-1); 

    // 1. Draw BLUE Reference
    noFill();
    stroke(0, 0, 255);
    strokeWeight(2);
    beginShape();
    for (complex c : Xn) {
        vertex(c.re, c.im);
    }
    if (Xn.size() > 0) vertex(Xn.get(0).re, Xn.get(0).im);
    endShape();

    // 2. Draw Epicycles
    PVector tip = drawEpicycles(0,0,1,time,Xk);
    
    // 3. Draw GREEN Trail (Fading)
    path.add(tip);
    
    // Remove the oldest point if the path gets too long
    if (path.size() > trailLength) {
        path.remove(0);
    }
    
    strokeWeight(3);
    noFill();
    
    // Draw individual lines so we can change alpha (opacity) for each one
    for (int i = 0; i < path.size() - 1; i++) {
        PVector p1 = path.get(i);
        PVector p2 = path.get(i+1);
        // Map 'i' (position in list) to transparency (0 to 255)
        // Oldest points (index 0) are transparent, Newest (index size) are opaque
        float alpha = map(i, 0, path.size(), 0, 255);
        stroke(0, 255, 0, alpha);
        line(p1.x, p1.y, p2.x, p2.y);
    }
    
    time += dt* 0.2; 

	if (time >= TAU) {
        time -= TAU; 
    }
}

PVector drawEpicycles(float x, float y, float scale, float time, ArrayList<complex> Xk){
    float prevX = x;  
    float prevY = y;  

    for (complex epicycle : Xk) {
		// if (epicycle.Frequency < Xk.size()) {
		if (epicycle.Frequency < Xk.size()) {
			float currX = prevX + epicycle.Amplitude * scale * cos(epicycle.Frequency * time + epicycle.Phase);
			float currY = prevY + epicycle.Amplitude * scale * sin(epicycle.Frequency * time + epicycle.Phase);

			stroke(255, 150); 
			strokeWeight(2);
			noFill();
			circle(prevX, prevY, epicycle.Amplitude * 2);
			stroke(255, 150);
			line(prevX,prevY, currX, currY);
			prevX = currX;
			prevY = currY;
		}
    }
	stroke(0,255,0);
	strokeWeight(12);
	point(prevX,prevY);
    return new PVector(prevX, prevY);
}
