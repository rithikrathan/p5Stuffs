boolean export = true;
boolean showRef = false;
boolean useJson = false;
boolean showEpicycles = true;
boolean showGradient = true;

// Gradient Toggles
boolean usePenGradient = true;
boolean useEpicycleGradient = false;

// Gradient Colors
color defaultPenColor = #eebb69;
color[] penColors = {
#0000FF,  // Blue
#00FF00, // Green
#FFFF00, // Yellow
#FF7F00, // Orange
#FF0000, // Red
};

color defaultEpicycleColor = #696969;
color[] epicycleColors = {
#00FFFF, // Cyan
#0099FF, // Blueish
#0000FF, // Blue
#9900FF, // Purple
#FF00FF // Magenta
};

int sortType = 2;
int grad = 12; // use to define the gradient
int cycleCount = 23;
int trailLength = 300;
int resolution = -1;
int initialDelay = 0; // in seconds, starts the sketch after 5 seconds
int FrameRate = 60;

float dt;
float alpha;
float time = 0;
float increment = 0.3;
float speedMultiplier = 0.069;
float digScale = 1.6;

String jsonName = "./diagrams/heart.json";
String shapeName = "circle";

ArrayList<complex> Xk = new ArrayList<complex>();
ArrayList<complex> temp_Xk = new ArrayList<complex>();
ArrayList<complex> Xn = new ArrayList<complex>();
math2samples m2s = new math2samples(increment);
// ArrayList<PVector> path = new ArrayList<PVector>(); // using this is expensive

PVector[] path = new PVector[trailLength];
PVector pen;
int pathHead = 0;
int pathCount = 0;

void setup(){
	frameRate(FrameRate);
	size(750,750);

	background(10,10,30);
	translate(375,375);
	scale(1,-1);
	drawAxes();
	delay(initialDelay * 1000);

	time = 0;
	// handle loading the Xk list here either from a function or from json
	if (useJson) {

		importJson(jsonName);
	}	else{
		m2s.heartCurve(0,0,10);
	}

	// use that list to calculate dft and other stuffs

	Xk = dft(Xn);  // solve Discrete Fourier Transform
	temp_Xk = Xk;

	// Sort by Amplitude
	switch (sortType) {
		case 0:
			println("Unsorted");
			break;
		case 1:
			println("Sorted ascending order");
			Xk.sort((a, b) -> Float.compare(a.Amplitude, b.Amplitude));
			break;

		case 2:
			println("Sorted decending order");
			Xk.sort((a, b) -> Float.compare(b.Amplitude, a.Amplitude));
			break;

		default:
			break;
	}

	println("List size: " + Xk.size());

	dt = TAU / Xk.size(); // calculate dt
}

void draw(){ 
	background(10,10,30);
	translate(375,375);
	scale(1,-1);

	// draw logic
	drawAxes();

	// NOTE: hope this works for the -m to m-1 range unlike 0 to N - 1 i used before
	if (showRef) {
		noFill();
		stroke(0, 0, 255);
		strokeWeight(2);
		beginShape();
		for (complex c : Xn) {
			vertex(c.re * digScale, c.im * digScale);
		}
		if (Xn.size() > 0) vertex(Xn.get(0).re, Xn.get(0).im);
		endShape();
	}

	// draw the curve either using the idft() or directly using the last epicircle position
	if (showEpicycles) {
		pen = drawEpicycles(0,0,digScale,time,Xk);
	} else {
		// get only the curve using idft() without calculating the epicycles
		pen = idft(0,0,temp_Xk,time, digScale);
	}


	// Previous expensive way to remove the trails
	// path.add(pen);
	// if (path.size() > trailLength) {
	// path.remove(0);
	// }

	// this is less expensive method for handling trails
	path[pathHead] = pen;
	pathHead = (pathHead + 1)% trailLength;
	if(pathCount < trailLength) pathCount++;

	strokeWeight(5); // weight of the pen
	noFill();

	// for (int i = 0; i < path.size() - 1; i++) {
	//     PVector p1 = path.get(i);
	//     PVector p2 = path.get(i+1);
	//     float alpha = map(i, 0, path.size(), 0, 255);
	//     stroke(0, 255, 0, alpha);
	//     line(p1.x, p1.y, p2.x, p2.y);
	// }

	int tailIndex = (pathHead - pathCount + trailLength) % trailLength;

	for (int i = 0; i < pathCount - 1; i++) {
		int idx1 = (tailIndex + i) % trailLength;
		int idx2 = (tailIndex + i + 1) % trailLength;

		PVector p1 = path[idx1];
		PVector p2 = path[idx2];

		if (showGradient) {
			alpha = map(i,0,pathCount, 0, 255);
		} else{
			alpha = 255;
		}

		if (usePenGradient) {
			stroke(getGradientColor(i, pathCount, penColors), alpha);
		} else {
			stroke(defaultPenColor, alpha);
		}

		line(p1.x, p1.y, p2.x, p2.y);
	}

	time += dt * speedMultiplier; 

	if (time >= TAU) {
		if (export && cycleCount == 0) {
			println("stopped exporting");
			export = false;
		}
		cycleCount -= 1;
		time -= TAU; 
	}

	// some other logic
	if (export) {
		saveFrame("videoFrames/frame-######.png");
	}
}

color getGradientColor(int index, int total, color[] palette) {
	if (total <= 1) return palette[0];
	float t = map(index, 0, total, 0, palette.length - 1);
	int idx = int(t);
	float amt = t - idx;
	if (idx >= palette.length - 1) return palette[palette.length - 1];
	return lerpColor(palette[idx], palette[idx+1], amt);
}


void drawAxes() {
	stroke(100);     
	strokeWeight(1); 
	fill(100);
	float axisLen = 360; 
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
	text("+Re", axisLen - 20, 20);      // Right
	text("-Re", -axisLen + 20, 20);     // Left
	text("+Im", 20, -axisLen + 20);     // Top (Note negative Y coord)
	text("-Im", 20, axisLen - 20);      // Bottom (Note positive Y coord)
	popMatrix();
}
