import com.krab.lazy.LazyGui;

LazyGui gui;
float radius = 100;
boolean export = false;
boolean playing = false;
float thetaMain;
float thetaFrom;
float thetaTo;
float time = 0;
float dt = 0.23;

class Point {
	float x, y;
	color col;

	Point(float x, float y, color col) {
		this.x = x;
		this.y = y;
		this.col= col;
	}

	// x′ = xcos(θ) − ysin(θ)
	// y′ = xsin(θ) + ycos(θ)

	void rotate(float theta) {
		float a = sin(theta);
		float b = cos(theta);

		float prev_x = this.x; // temp

		this.x = prev_x * b - this.y * a;
		this.y = prev_x * a + this.y * b;
	}
}

class Complex extends Point {
	Complex(float re, float im, color col) {
		super(re,im,col);
	}


	// (x+iy) * e^iθ = (x+iy)(cosθ+isinθ)

	// x′ = Re((x+iy)(cosθ+isinθ)) = xcosθ − ysinθ
	// y′= Im((x+iy)(cosθ+isinθ)) = xsinθ + ycosθ

	void rotate(float theta){
	}

	void add(Complex c){
	}

	void multiply(Complex c){
	}

}

Point pt = new Point(radius,0, #4dccb3);
Point ptt = new Point(radius,0, #f24447);
Point ptf = new Point(radius,0, #64b366);

void setup() {
	size(600, 600, P2D);
	gui = new LazyGui(this);
	smooth(8);
	calculate();
}

void draw() {
	background(10,10,30);
	translate(width/2, height/2);
	scale(1,-1);
	drawAxes();
	// logic here
	calculate();

    
    drawPointLabel("v", pt.x, pt.y, pt.col, false);
    drawPointLabel("V", ptf.x, ptf.y, ptf.col, false);
    drawPointLabel("V'", ptt.x, ptt.y, ptt.col, false);


	// Draw the circle based on the slider
	stroke(100,100,250);
	strokeWeight(3);
	noFill();
	circle(0, 0, radius * 2);

	// main point
	stroke(pt.col);
	strokeWeight(2);
	dashedLine(0, 0, pt.x, pt.y, 8, 10);

	// stroke(100,250,100);
	stroke(pt.col);
	strokeWeight(12);
	point(pt.x, pt.y);

	// from point v
	// stroke(100,250,200);
	stroke(ptf.col);
	strokeWeight(2);
	dashedLine(0, 0, ptf.x, ptf.y, 8, 10);

	stroke(ptf.col);
	strokeWeight(12);
	point(ptf.x, ptf.y);

	// to point v'
	// stroke(200,250,100);
	stroke(ptt.col);
	strokeWeight(2);
	dashedLine(0, 0, ptt.x, ptt.y, 8, 10);

	stroke(ptt.col);
	strokeWeight(12);
	point(ptt.x, ptt.y);
	
	if (playing) {
		time += dt;
		// calculate interpolation and other stuffs
		playing = false;
		time = 0;
	} else{
		pt.x = ptf.x;
		pt.y = ptf.y;
	}

	if (export) {
		// handle save frame logic here
	}

	handleGui();
}

void handleGui() {
	radius = gui.slider("radius", 100, 10, 200);
	thetaMain = gui.slider("thetaMain", 100, -1, 360);
	thetaFrom = gui.slider("thetaFrom", 100, -1, 360);
	thetaTo = gui.slider("thetaTo", 100, -1, 360);
	dt = gui.slider("dt", 1, 0, 360);

	// pt.x = radius;
	// ptt.x = -radius;
	// ptf.y = radius;
	
	// if (thetaMain == 360) {
	// 	thetaMain = 0;
	// 	gui.sliderSet("thetaMain",0);
	// }

	if (thetaFrom== 360) {
		thetaFrom= 0;
		gui.sliderSet("thetaFrom",0);
	}

	if (thetaTo == -1) {
		thetaTo = 359;
		gui.sliderSet("theta To ",359);
	}

	if (gui.button("play")) {
		playing = true;
	}

	if (thetaFrom== -1) {
		thetaFrom= 359;
		gui.sliderSet("thetaFrom",359);
	}

	if (thetaTo == -1) {
		thetaTo = 359;
		gui.sliderSet("theta To ",359);
	}

	if (gui.button("play")) {
		playing = true;
	}

	if (gui.button("reset")) {
		radius = 100;
		gui.sliderSet("radius",100);

		thetaMain = 0;
		gui.sliderSet("thetaMain",0);

		thetaFrom = 0;
		gui.sliderSet("thetaFrom",0);

		thetaTo = 0;
		gui.sliderSet("thetaTo",0);
	}

	if (gui.button("quit")) {
		exit();
	}

	if (gui.hasChanged("radius")||
		gui.hasChanged("thetaMain")||
		gui.hasChanged("thetaFrom")||
		gui.hasChanged("thetaTo")
		){
		// calculate();
	}
}

void calculate() {
	ptt.y = 0;
	ptt.x = radius;
	ptf.y = 0;
	ptf.x = radius;

	ptf.rotate(radians(thetaFrom));
	ptt.rotate(radians(thetaTo));
}

void drawAxes() {
	stroke(100);     
	strokeWeight(1); 
	fill(100);
	float axisLen = 275; 
	line(-axisLen, 0, axisLen, 0); 
	line(0, -axisLen, 0, axisLen); 
	float arrowSize = 6;
	pushMatrix();
	translate(axisLen, 0);
	triangle(0, 0, -arrowSize, -arrowSize/2, -arrowSize, arrowSize/2);
	popMatrix();
	pushMatrix();
	translate(-axisLen, 0);
	triangle(0, 0, arrowSize, -arrowSize/2, arrowSize, arrowSize/2);
	popMatrix();
	pushMatrix();
	translate(0, axisLen);
	triangle(0, 0, -arrowSize/2, -arrowSize, arrowSize/2, -arrowSize);
	popMatrix();
	pushMatrix();
	translate(0, -axisLen);
	triangle(0, 0, -arrowSize/2, arrowSize, arrowSize/2, arrowSize);
	popMatrix();
	pushMatrix();
	scale(1, -1); 
	textSize(14);
	fill(150);
	textAlign(CENTER, CENTER);
	text("+x", axisLen - 20, 20);      // Right
	text("-x", -axisLen + 20, 20);     // Left
	text("+y", 20, -axisLen + 20);     // Top (Note negative Y coord)
	text("-y", 20, axisLen - 20);      // Bottom (Note positive Y coord)
	popMatrix();
}
