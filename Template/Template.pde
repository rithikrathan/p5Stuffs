boolean export = false;

void setup() {
	frameRate(60);
	size(800, 800);
	background(100,100,190);
	scale(1,-1);
}

void draw() {
	watermarkBackground(color(10,10,30), color(40), "Template");
	translate(400,400);
	scale(1,-1);

	// draw logic
	drawAxes();

	if (export) {
		saveFrame("videoFrames/frame-########.png");
	}
}
