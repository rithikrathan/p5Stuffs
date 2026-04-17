//objects
ArrayList<point> Points = new ArrayList<point>();

//normal variabls
boolean export = false;
float digScale  = 10;
float increment = 0.02;
void setup() {
	frameRate(60);
	size(800, 800);
	background(100,100,190);
	scale(1,-1);
}

class point {
    float x, y;

    point(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

void heartCurve(float cx, float cy, float scale) {
    for (float t = 0; t < TAU; t += increment) {
        // We use pow(sin(t), 3) for the X shape
        float xVal = 16 * pow(sin(t), 3);
        float yVal = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
        float x = cx + scale * xVal;
        float y = cy - scale * yVal; 
        Points.add(new point(x, -y));
    }
}

void draw() {
	background(3,3,10);
	translate(400,400);
	scale(1,-1);

	// draw logic
	drawAxes();
    heartCurve(0, 0, digScale);

    noFill();
    beginShape();
		for (point vert: Points) {
			vertex(vert.x , vert.y );
		}
    endShape();

	if (export) {
		saveFrame("videoFrames/frame-######.png");
	}
}
