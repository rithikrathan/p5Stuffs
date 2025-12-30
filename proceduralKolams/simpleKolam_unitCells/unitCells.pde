import com.krab.lazy.*;

LazyGui gui;

// =-=-=-=-=-=[ variables ]=-=-=-=-= //
final point origin = new point(0,0);

// =-=-=-=-=-=[ boolean variables ]=-=-=-=-= //


// =-=-=-=-=-=[ ciriticalSection ]=-=-=-=-= //
PVector originOffset;
float patternId;
float matrixDensity = 145;

// =-=-=-=-=-=[ Objects ]=-=-=-=-= //
pattern pattern = new pattern(12,255,255,255);
point[] polygonVertices = {
	new point(150,150),
	new point(-150,150),
	new point(-150,-150),
	new point(150,-150)
};

// =-=-=-=-=-=[ Jobs ]=-=-=-=-= //
void setup(){
	size(600,600,P2D);
	gui =  new LazyGui(this);
}


void handleGui(LazyGui gui){
	patternId = gui.slider("patternId",patternId, 0, 16);
	originOffset  = gui.plotXY("originOffset", width /2, height/2);

	if (gui.button("resetValues")) {
		patternId = 27;
		gui.sliderSet("patternId",27);
			
		originOffset.set(width/2,height/2);
		gui.plotSet("originOffset", width /2, height/2);
	}

	if (gui.button("stop")) {
		exit();
	}
}

void draw(){
	//basic setup
	background(10);
	handleGui(gui);
	translate(originOffset.x,originOffset.y); // set the origin to the middle of the screen
	scale(1,-1);
	// some draw logic
	noFill();

	strokeWeight(3);
	stroke(0,80,0);
	line(0,0,0,150);
	line(0,0,150,0);
	line(0,0,0,-150);
	line(0,0,-150,0);

	for (int i = 0; i < polygonVertices.length; i++) {
		int j =  (i + 1) % polygonVertices.length;
		point p = polygonVertices[i];
		point q = polygonVertices[j];

		stroke(0,255,0);
		strokeWeight(3);
		line(p.x,p.y,q.x,q.y);
		strokeWeight(12);
		point(p.x,p.y);
	}

	stroke(255,255,255);
	strokeWeight(10);
	drawCell(origin);

	// draw gui 
	gui.draw();
}

// =-=-=-=-=-=[ helper classes ]=-=-=-=-= //
class point{
	float x;
	float y;
	
	point(float x, float y){
		this.x = x;
		this.y = y;
	}
}


// =-=-=-=-=-=[ helper methods ]=-=-=-=-= //
void drawCell(point center) {
	switch (int(patternId)) {
		case 0:
			pattern.Point(center, matrixDensity);
			break;
		case 1:
			pattern.circle(center, matrixDensity);
			break;
		case 2:
			pattern.connectedUp(center, matrixDensity);
			break;
		case 3:
			pattern.connectedDown(center, matrixDensity);
			break;
		case 4:
			pattern.connectedLeft(center, matrixDensity);
			break;
		case 5:
			pattern.connectedRight(center, matrixDensity);
			break;
		case 6:
			pattern.catEars_bottomLeft(center, matrixDensity);
			break;
		case 7:
			pattern.catEars_bottomRight(center, matrixDensity);
			break;
		case 8:
			pattern.catEars_topLeft(center, matrixDensity);
			break;
		case 9:
			pattern.catEars_topRight(center, matrixDensity);
			break;
		case 10:
			pattern.eyeHorizontal(center, matrixDensity);
			break;
		case 11:
			pattern.eyeVertical(center, matrixDensity);
			break;
		case 12:
			pattern.bottomPizzaSlice(center, matrixDensity);
			break;
		case 13:
			pattern.topPizzaSlice(center, matrixDensity);
			break;
		case 14:
			pattern.leftPizzaSlice(center, matrixDensity);
			break;
		case 15:
			pattern.rightPizzaSlice(center, matrixDensity);
			break;
		case 16:
			pattern.diamond(center, matrixDensity);
			break;
		default:
			break;
	}
}
