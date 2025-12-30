import com.krab.lazy.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;


LazyGui gui;

// =-=-=-=-=-=[ variables ]=-=-=-=-= //
final point origin = new point(0,0);
int boundryValue = 300;


// =-=-=-=-=-=[ boolean variables ]=-=-=-=-= //
boolean fill = false;


// =-=-=-=-=-=[ ciriticalSection ]=-=-=-=-= //
float matrixDensity = 27;

PVector originOffset;

// =-=-=-=-=-=[ Objects ]=-=-=-=-= //
point[] polygonVertices = {
	new point(150,150),
	new point(-150,150),
	new point(-150,-150),
	new point(150,-150)
};

ArrayList<unitCell> unitCells = new ArrayList<unitCell>();
ArrayDeque<unitCell> stack =  new ArrayDeque<unitCell>();
Queue<unitCell> queue = new ArrayDeque<unitCell>();


// =-=-=-=-=-=[ Jobs ]=-=-=-=-= //
void setup(){
	size(600,600,P2D);
	gui =  new LazyGui(this);
}

void handleGui(LazyGui gui){
	matrixDensity = gui.slider("matrixDensity", matrixDensity, 15, 100);
	originOffset  = gui.plotXY("originOffset", width /2, height/2);

	if (gui.button("resetValues")) {
		matrixDensity = 27;
		gui.sliderSet("matrixDensity",27);
			
		originOffset.set(width/2,height/2);
		gui.plotSet("originOffset", width /2, height/2);
	}

	if (gui.button("stop")) {
		exit();
	}
}

// initialize stack
// start from the origin
// push the origin to the stack
// loopStart:
//		1) pop unitCell from the stack
//		2) add it to unitCells
//		3) create 4 new unitCells and push them to stack
//	loop end.

void depthFirst(){
	unitCells.clear();
	unitCell start =  new unitCell(origin.x, origin.y, 0);

	stack.push(start);

	while (!stack.isEmpty()) {
		unitCell curr = stack.pop();

		// if (containedIn(curr, polygonVertices)) {
		// 	unitCells.add(curr);
		// }
		unitCells.add(curr);

		unitCell[] neighbours = {
			new unitCell(curr.x , curr.y + matrixDensity, 0),
			new unitCell(curr.x + matrixDensity, curr.y , 0),
			new unitCell(curr.x , curr.y - matrixDensity, 0),
			new unitCell(curr.x - matrixDensity, curr.y , 0)
		};

		for (unitCell next : neighbours) {
			if (next.inBounds() && next.notIn(unitCells)) {
				if (containedIn(next,polygonVertices)) {
					stack.push(next);
				}
			}
		}
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

	if (gui.hasChanged("matrixDensity")) {
		depthFirst();
	}

	for (unitCell u : unitCells){
		if (containedIn(u,polygonVertices)) {
			stroke(255,50,50);
		}else {
			stroke(255,255,255);
		}
		point(u.x,u.y);
	}

	for (int i = 0; i < polygonVertices.length; i++) {
		point a = polygonVertices[i];
		point b = polygonVertices[(i+1) % polygonVertices.length];
		strokeWeight(3);
		stroke(155,155,255);
		line(a.x, a.y, b.x,b.y);
		strokeWeight(8);
		stroke(255,255,0);
		point(a.x,a.y);
	}

	strokeWeight(6);
	point(origin.x, origin.y);

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

	public boolean notIn(ArrayList<unitCell> UnitCells){
		for (unitCell u : UnitCells){
			if (u.x == this.x && u.y == this.y) {
				return false;
			}
		}
		return true;
	}

	public boolean inBounds() {
		return this.x >= -boundryValue && this.x <= boundryValue &&
			this.y >= -boundryValue && this.y <= boundryValue;
	}
}

// =-=-=-=-=-=[ helper methods ]=-=-=-=-= //
//
// # found the culprit
//
// raycasting to check if the point is in the polygon

boolean isInBetween(float y, float y1, float y2){
    return (y > min(y1, y2)) && (y <= max(y1, y2));
}

point getIntersection(unitCell rayPoint, point a, point b){
    // ray is horizontal → y is known
    float x =
        a.x + (rayPoint.y - a.y) *
        (b.x - a.x) / (b.y - a.y);

    return new point(x, rayPoint.y);
}

boolean containedIn(unitCell guidePoint, point[] polygon){
    int count = 0;

    for (int i = 0; i < polygon.length; i++) {
        point a = polygon[i];
        point b = polygon[(i + 1) % polygon.length];

        // skip horizontal edges
        if (a.y == b.y) continue;

        if (isInBetween(guidePoint.y, a.y, b.y)) {
            point p = getIntersection(guidePoint, a, b);
            if (p.x > guidePoint.x) count++;
        }
    }

    return (count & 1) == 1;
}

