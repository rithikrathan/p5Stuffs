import com.krab.lazy.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;


LazyGui gui;

// =-=-=-=-=-=[ variables ]=-=-=-=-= //
int nf = 0;
int nt = 0;
final point origin = new point(0,0);


// =-=-=-=-=-=[ boolean variables ]=-=-=-=-= //
volatile boolean compute = false;

boolean showPolygon = true;
boolean showSection = true;
boolean showPattern = false;
boolean showGuidePoints = false;
boolean showOrigin = true;

// =-=-=-=-=-=[ ciriticalSection ]=-=-=-=-= //
float testPattern = 1;
float matrixDensity = 27;
float radialSubdivision = 6;

PVector originOffset;
PVector scaleFactor;

// =-=-=-=-=-=[ Objects ]=-=-=-=-= //
final Object mutex = new Object();
patterns pattern = new patterns();
ArrayList<point> polygonVertices =  new ArrayList<point>();

ArrayList<unitCell> unitCells = new ArrayList<unitCell>();
ArrayList<unitCell> frameBuffer = new ArrayList<unitCell>();

// =-=-=-=-=-=[ Jobs ]=-=-=-=-= //
void setup(){
	size(600,600,P2D);
	gui =  new LazyGui(this);
	thread("calculate");
}

void calculate(){
	println("thread started???");
	while (true) {
		if (compute) {
			println("calculating");
			int count = 0;
			synchronized (mutex){
				println("calculation thread aquired mutex lock");
				// step 1: Calculate polygon
				polygonVertices.clear();
				for (int i = 0; i < int(radialSubdivision); i++) {
					float theta = i * TAU / radialSubdivision;
					float x = scaleFactor.x * cos(theta);
					float y = scaleFactor.y * sin(theta);
					polygonVertices.add(new point(x,y));
				}

				// step 2: Generate UnitCells
				Queue<unitCell> q = new ArrayDeque<unitCell>();

				unitCell start = new unitCell(origin.x, origin.y,0);

				q.add(start);

				while (!q.isEmpty()) {
					unitCell curr = q.poll();

					if (!containedIn(curr, polygonVertices)) continue;

					unitCells.clear();
					unitCells.add(curr);

					unitCell[] neighbors = {
						new unitCell(curr.x, curr.y + matrixDensity,0),
						new unitCell(curr.x + matrixDensity, curr.y,0),
						new unitCell(curr.x, curr.y - matrixDensity,0),
						new unitCell(curr.x - matrixDensity, curr.y,0)
					};

					// using critical section from calculation thread
					for (unitCell u: neighbors) {
						if (notIn(u,unitCells)) {
							count ++;
							q.add(u);
						}
					}
					println(count);
					count = 0;
				}
				
				// step 3: Generate pattern
				
				// set the compute variable to false
				compute = false;
				println("reset compute flag");
			}
		}
	}
}

void handleGui(LazyGui gui){
	testPattern = gui.slider("testPattern", testPattern, 0, 16);
	matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 100);
	radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);

	originOffset  = gui.plotXY("originOffset", width /2, height/2);
	scaleFactor  = gui.plotXY("scaleFactor", 50, 50);

	if (gui.button("resetValues")) {
		testPattern = 0;
		gui.sliderSet("testPattern", 0);

		matrixDensity = 27;
		gui.sliderSet("matrixDensity",27);
			
		radialSubdivision = 6;
		gui.sliderSet("radialSubdivision",6);

		originOffset.set(width/2,height/2);
		gui.plotSet("originOffset", width /2, height/2);

		scaleFactor.set(50,50);
		gui.plotSet("scaleFactor",50,50);
	}

	if (gui.button("stop")) {
		exit();
	}

	// calculate everytime a value changes using shared variable
	if (gui.hasChanged("radialSubdivision") ||
		gui.hasChanged("scaleFactor") || 
		gui.hasChanged("matrixDensity")){

		compute = true;
		println("set compute flag");
	}
}

void draw(){
	//basic setup
	background(30);
	handleGui(gui);
	translate(originOffset.x,originOffset.y); // set the origin to the middle of the screen

	// some draw logic
	strokeWeight(6);
	noFill();
	stroke(255,255,255);

	// using critical section by the animation thread
	synchronized (mutex){
		for ( int i = 0; i < polygonVertices.size(); i++) {
			// draw shape
			point a = polygonVertices.get(i);
			point b = polygonVertices.get((i + 1) % polygonVertices.size());
			stroke(100, 179, 100);
			strokeWeight(2);
			line(a.x, a.y, b.x, b.y);

			// show segments
			stroke(100, 100, 200);
			strokeWeight(1);
			line(0, 0, b.x, b.y);

			// show vertices
			stroke(0, 255, 0);
			strokeWeight(7);
			point(a.x, a.y);
		}

		for(unitCell u : unitCells){
			drawCell(u);
		}

	}
	

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

class unitCell extends point{
	int patternId;

	unitCell(float x, float y, int id){
		super(x,y);
		this.patternId = id;
	}

	public boolean isEqual(unitCell another){
		if (this.patternId == another.patternId && this.x == another.x && this.y ==  another.y) {return true;}
		return false;
	}
}

// =-=-=-=-=-=[ helper methods ]=-=-=-=-= //

// raycasting to check if the point is in the polygon
boolean isInBetween(float y, float y1, float y2){
	if (y1 > y2) {
		return y <= y1 && y > y2;
	} else {
		return y <= y2 && y > y1;
	}
}

point getIntersection(point rayPoint, point a, point b){
	point pointOfIntersection = new point(a.x, rayPoint.y);
	try {
		float slope = (b.y - a.y)/(b.x -a.x);
		pointOfIntersection.y = rayPoint.y;
		pointOfIntersection.x = ((pointOfIntersection.y - a.y)/slope)+a.x;
		return pointOfIntersection;
	}
	catch (ArithmeticException e) {
		println("encountered arithmetic exception");
		return pointOfIntersection;
	}
}

boolean containedIn(point guidePoint, ArrayList<point> polygon){
	int count = 0;
	for (int i = 0; i < polygon.size(); i++) {

		point vert_a = polygon.get(i); //current point
		point vert_b = polygon.get((i+1) % polygon.size()); // next point

		if (vert_a.x != vert_b.x && isInBetween(guidePoint.y, vert_a.y, vert_b.y)) {
			point pointOfIntersection = getIntersection(guidePoint, vert_a, vert_b);
			if (pointOfIntersection.x > guidePoint.x) {
				count ++;
			}
		}
	}

	if (count % 2 == 0) {return false;};
	return true;
}

boolean notIn(unitCell curr, List<unitCell> UnitCells){
	for (unitCell UnitCell: UnitCells){
		nf ++;
		println("num of false: " + nf);
		if (UnitCell.isEqual(curr)) {return false;} 
	}
	nt ++;
	println("num of true: " + nt);
	return true;
}


// method to draw a pattern (might change this in the future)
void drawCell(unitCell center) {
	float dick = 1; //magic value: i call this dick cus i insert it anywhere it fits
	switch (center.patternId) {
		case 0:
			pattern.Point(center, matrixDensity/dick);
			break;
		case 1:
			pattern.circle(center, matrixDensity/dick);
			break;
		case 2:
			pattern.connectedUp(center, matrixDensity/dick);
			break;
		case 3:
			pattern.connectedDown(center, matrixDensity/dick);
			break;
		case 4:
			pattern.connectedLeft(center, matrixDensity/dick);
			break;
		case 5:
			pattern.connectedRight(center, matrixDensity/dick);
			break;
		case 6:
			pattern.catEars_bottomLeft(center, matrixDensity/dick);
			break;
		case 7:
			pattern.catEars_bottomRight(center, matrixDensity/dick);
			break;
		case 8:
			pattern.catEars_topLeft(center, matrixDensity/dick);
			break;
		case 9:
			pattern.catEars_topRight(center, matrixDensity/dick);
			break;
		case 10:
			pattern.eyeHorizontal(center, matrixDensity/dick);
			break;
		case 11:
			pattern.eyeVertical(center, matrixDensity/dick);
			break;
		case 12:
			pattern.bottomPizzaSlice(center, matrixDensity/dick);
			break;
		case 13:
			pattern.topPizzaSlice(center, matrixDensity/dick);
			break;
		case 14:
			pattern.leftPizzaSlice(center, matrixDensity/dick);
			break;
		case 15:
			pattern.rightPizzaSlice(center, matrixDensity/dick);
			break;
		case 16:
			pattern.diamond(center, matrixDensity/dick);
			break;
		default:
			break;
	}
}
