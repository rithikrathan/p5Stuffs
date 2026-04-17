boolean export = false;


class Point {
    float x, y;
    color col;

    Point(float x, float y, color col) {
        this.x = x;
        this.y = y;
        // this.col = col;
    }

    void rotate(float theta) {
        float a = sin(theta);
        float b = cos(theta);

        float prev_x = this.x; // temp

        this.x = prev_x * b - this.y * a;
        this.y = prev_x * a + this.y * b;
    }

}

void setup() {
	frameRate(60);
	size(800, 800);
	background(100,100,190);
	scale(1,-1);
}

void draw() {
	background(10,10,30);
	translate(400,400);
	scale(1,-1);
	// draw logic
	drawAxes();

	if (export) {
		saveFrame("videoFrames/frame-######.png");
	}
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
	text("+X", axisLen - 20, 20);      // Right
	text("-X", -axisLen + 20, 20);     // Left
	text("+Y", 20, -axisLen + 20);     // Top (Note negative Y coord)
	text("-Y", 20, axisLen - 20);      // Bottom (Note positive Y coord)
	popMatrix();
}







