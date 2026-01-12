// -=-=-=-=-=-=-=-=[ GLOBALS ]=-=-=-=-=-=-=-=-
ArrayList<complex> Xk = new ArrayList<complex>();
ArrayList<complex> Xn = new ArrayList<complex>(); // Stores the original Blue Shape
ArrayList<PVector> path = new ArrayList<PVector>(); // Stores the Green Trail

// TOGGLE THIS TO ENABLE/DISABLE EXPORT
boolean export = true; 
boolean showRef = true;
int sortType = 2;

float time;
float dt;
int trailLength = 650; 
int resolution = -1;
float speedMultiplier = 0.4;
float digScale = 1.3;

String jsonName = "diagrams/yoni.json"; 

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

    // CHANGE: Load a single JSONObject instead of a JSONArray
    // The file structure is now: { "name": "...", "points": [...] }
    JSONObject json = loadJSONObject(jsonName);
    
    // We access the points array directly from the root object
    JSONArray points = json.getJSONArray("points");
    
    println("Loading Shape: " + json.getString("name"));

    // Parse JSON into Complex Numbers
    for (int i = 0; i < points.size(); i++) {
        JSONObject p = points.getJSONObject(i);
        float x = p.getFloat("x");
        float y = p.getFloat("y");
        Xn.add(new complex(x, y));
    }

    // The rest of the logic remains exactly the same
    Xk = dft(Xn); 
    
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
    dt = TAU / Xk.size();
}

// -=-=-=-=-=-=-=-=[ DRAW LOOP ]=-=-=-=-=-=-=-=-
void draw(){
    background(10,10,30);
    translate(300,300);
    scale(1,-1); 

    // 0. Draw Axes (Added Feature)
    drawAxes();

    // 1. Draw BLUE Reference
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

    // 2. Draw Epicycles
    PVector tip = drawEpicycles(0,0,digScale,time,Xk);
    
    // 3. Draw GREEN Trail (Fading)
    path.add(tip);
    if (path.size() > trailLength) {
        path.remove(0);
    }

    strokeWeight(3);
    noFill();
    for (int i = 0; i < path.size() - 1; i++) {
        PVector p1 = path.get(i);
        PVector p2 = path.get(i+1);
        float alpha = map(i, 0, path.size(), 0, 255);
        stroke(0, 255, 0, alpha);
        line(p1.x, p1.y, p2.x, p2.y);
    }
    
    time += dt * speedMultiplier; 

    if (time >= TAU) {
		if (export) {
			println("stopped exporting");
			export = false;
		}
        time -= TAU; 
    }
    
    // EXPORT FRAMES ONLY IF boolean export IS TRUE
    if (export) {
        saveFrame("videoFrames/frame-######.png");
    }
}

// -=-=-=-=-=-=-=-=[ HELPER FUNCTIONS ]=-=-=-=-=-=-=-=-

void drawAxes() {
    stroke(100);     // Grey color for axes
    strokeWeight(1); // Thin line
    fill(100);
    
    float axisLen = 280; // Length from center
    
    // DRAW LINES
    line(-axisLen, 0, axisLen, 0); // Real Axis (X)
    line(0, -axisLen, 0, axisLen); // Imaginary Axis (Y)
    
    // DRAW ARROWS
    float arrowSize = 6;
    
    // +Re Arrow (Right)
    pushMatrix();
    translate(axisLen, 0);
    triangle(0, 0, -arrowSize, -arrowSize/2, -arrowSize, arrowSize/2);
    popMatrix();

    // -Re Arrow (Left)
    pushMatrix();
    translate(-axisLen, 0);
    triangle(0, 0, arrowSize, -arrowSize/2, arrowSize, arrowSize/2);
    popMatrix();
    
    // +Im Arrow (Top - remember Y is positive up due to scale(1,-1))
    pushMatrix();
    translate(0, axisLen);
    triangle(0, 0, -arrowSize/2, -arrowSize, arrowSize/2, -arrowSize);
    popMatrix();

    // -Im Arrow (Bottom)
    pushMatrix();
    translate(0, -axisLen);
    triangle(0, 0, -arrowSize/2, arrowSize, arrowSize/2, arrowSize);
    popMatrix();

    // DRAW LABELS
    // We must un-flip the text so it is readable
    pushMatrix();
    scale(1, -1); // Invert Y back for text rendering
    
    textSize(14);
    fill(150);
    textAlign(CENTER, CENTER);
    
    // Because we flipped Y back, 'up' is now negative Y in this local matrix
    text("+Re", axisLen - 20, 20);      // Right
    text("-Re", -axisLen + 20, 20);     // Left
    text("+Im", 20, -axisLen + 20);     // Top (Note negative Y coord)
    text("-Im", 20, axisLen - 20);      // Bottom (Note positive Y coord)
    
    popMatrix();
}

PVector drawEpicycles(float x, float y, float scale, float time, ArrayList<complex> Xk){
    float prevX = x;  
    float prevY = y;  

    if (resolution == -1) {
        resolution = Xk.size();
    }

    for (complex epicycle : Xk) {
        float freq = epicycle.Frequency;

        if (freq > Xk.size() / 2) {
            freq -= Xk.size();
        }

        if (freq < resolution ) {
            float currX = prevX + epicycle.Amplitude * scale * cos(freq * time + epicycle.Phase);
            float currY = prevY + epicycle.Amplitude * scale * sin(freq * time + epicycle.Phase);
            stroke(255, 90); 
            strokeWeight(2); // Made circles slightly thinner
            noFill();
            circle(prevX, prevY, epicycle.Amplitude * 2 * scale);
            stroke(255, 90);
            line(prevX,prevY, currX, currY);
            strokeWeight(4);
            point(currX, currY); // Small point at joint
            
            prevX = currX;
            prevY = currY;
        }
    }
    stroke(0,255,0);
    strokeWeight(8);
    point(prevX,prevY);
    return new PVector(prevX, prevY);
}
