import com.krab.lazy.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;

LazyGui gui;
PGraphics pg;

int boundryValue = 300;
int winWidth = 600;
int winHeight = 600;
int pDensity = 1;
final point origin = new point(0,0);

volatile boolean compute = false;
volatile boolean redraw = false;

boolean evenMatrix = false;
boolean showPolygon = true;
boolean showSection = true;
boolean showPattern = false;
boolean showGuidePoints = false;
boolean showOrigin = true;

// New Mirroring Toggles
boolean mirrorHoriz = false;
boolean mirrorVert = false;

float testPattern = 1;
float matrixDensity = 27;
float radialSubdivision = 6;
float Seed = 69420;

PVector originOffset;
PVector scaleFactor;

pattern pattern = new pattern(4,255,255,255);
ArrayList<point> polygonVertices =  new ArrayList<point>();
ArrayList<unitCell> unitCells = new ArrayList<unitCell>();

void setup(){
	size(600,600,P2D);
	pixelDensity(pDensity);
	gui =  new LazyGui(this);
	pg = createGraphics(winWidth, winHeight, P2D);
	// randomSeed((long) Seed);
}

void calculate(){
	// step 1: Calculate polygon
	polygonVertices.clear();
	for (int i = 0; i < int(radialSubdivision); i++) {
		float theta = i * TAU / radialSubdivision;
		float x = scaleFactor.x * cos(theta);
		float y = scaleFactor.y * sin(theta);
		polygonVertices.add(new point(x,y));
	}

	// step 2: Generate UnitCells (Bottom-Right Quadrant)
	unitCells.clear();

	int prevCount = 0;

	//if odd matrix needs axisFilling
	if (!evenMatrix) {
		for (int y = 0; y > -boundryValue; y -= matrixDensity) {
			int currCount = 0; 
			for (int x = 0; x < boundryValue; x += matrixDensity) {
				int patternId;

				if (x == 0 && y == 0) {
					patternId = getRandomPattern(0b100000000000000010);
				} else{
					patternId = getRandomPattern(getBitList(unitCells, prevCount));
				}

				if (patternId == -1) {
					patternId = 0;
					println("invalid Pattern ID Encountered");
				}

				unitCell curr = new unitCell(x,y,patternId);

				setPattern(curr);

				if (containedIn(curr, polygonVertices)) {
					unitCells.add(curr);
					currCount++;
				}
			}
			prevCount = currCount; 
		}
	} else {
		for (int y = -int(matrixDensity / 2) ; y > -boundryValue; y -= matrixDensity) {
			int currCount = 0; 
			for (int x = int(matrixDensity / 2) ; x < boundryValue; x += matrixDensity) {

				int patternId;

				if (x == 0 && y == 0) {
					patternId = getRandomPattern(0b100000000000000010);
				} else{
					patternId = getRandomPattern(getBitList(unitCells,prevCount));
				}

				if (patternId == -1) {
					patternId = 0;
					println("invalid Pattern ID Encountered");
				}

				unitCell curr = new unitCell(x,y,patternId);

				setPattern(curr);

				if (containedIn(curr, polygonVertices)) {
					unitCells.add(curr);
					currCount++;
				}

			}
			prevCount = currCount; 
		}
	}

	// NEW: Apply mirroring logic after generating the base quadrant
	applyMirroring();

	compute = false;
	println("reset compute flag");
}

// NEW: Helper method to mirror generated cells
void applyMirroring() {
	int[] vMirrorImages = {0,1,2,3,5,4,6,7,10,11,8,9,12,13,15,14,16};
	int[] hMirrorImages = {0,1,3,2,4,5,6,7,9,8,11,10,13,12,14,15,16};

	// 1. Mirror Horizontally (Right -> Left)
	if (mirrorHoriz) {
		int currentSize = unitCells.size();
		for (int i = 0; i < currentSize; i++) {
			unitCell u = unitCells.get(i);
			// Skip x=0 to avoid duplicating the central axis
			if (u.x != 0) {
				unitCell m = new unitCell(-u.x, u.y, hMirrorImages[u.patternId]);
				setPattern(m); // Setup connections for the new cell
				unitCells.add(m);
			}
		}
	}

	// 2. Mirror Vertically (Bottom -> Top)
	// This mirrors both the original right side AND the newly created left side
	if (mirrorVert) {
		int currentSize = unitCells.size();
		for (int i = 0; i < currentSize; i++) {
			unitCell u = unitCells.get(i);
			// Skip y=0 to avoid duplicating the central axis
			if (u.y != 0) {
				unitCell m = new unitCell(u.x, -u.y, vMirrorImages[u.patternId]);
				setPattern(m);
				unitCells.add(m);
			}
		}
	}
}

boolean bitMasking(int bin, int mask){
	return (bin & mask) != 0;
}

void setPattern(unitCell u){
	int rcl = 0b11110010101001000;
	int bcl = 0b11011001110100000;
	u.patternMask = 0b1 << u.patternId;
	u.rightConnection = bitMasking(rcl,u.patternMask);
	u.bottomConnection = bitMasking(bcl, u.patternMask);
}

int getRandomPattern(int bitList){
	ArrayList<Integer> ids = new ArrayList<Integer>();
	for (int i = 0; i < 18; i++) {
		if(((bitList >> i) & 1) == 1){
			ids.add(i);
		}
	}

	if (ids.size() == 0) return -1; // Safety for empty list
	return ids.get((int) random(ids.size()));
}

// left has rc and top has bc ? as input
int getBitList(ArrayList<unitCell> array, int prevCount){

	boolean rc = random(1) > 0.5;
	boolean bc = random(1) > 0.5;

	// Check Left Neighbor (Previous element added)
	// Only valid if array is not empty
	if (array.size() > 0) {
		rc = array.get(array.size() - 1).rightConnection;
	}

	// Check Top Neighbor (Element directly above)
	// Only valid if we aren't in the first row (prevCount > 0) 
	// and if the array is big enough to look back.
	if (prevCount > 0 && array.size() >= prevCount) {
		// Logic: The cell above is exactly 'prevCount' steps back
		bc = array.get(array.size() - prevCount).bottomConnection;
	}

	//bitlist to get possible pattern lists
	if (rc & bc) {
		//lcitc
		return 0b10101100000000000;
	} else if (!rc & bc){ 
		//nlcitc
		return 0b10010010010000;
	} else if (rc & !bc){
		//lcintc
		return 0b1000001001000100;
	} else {
		//nlcintc
		return 0b00100010;
	}
}

void handleGui(LazyGui gui){
	testPattern = gui.slider("testPattern", testPattern, 0, 16);
	matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 200);
	radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);
	Seed  = gui.slider("randomSeed", Seed, 0, 99999);
	evenMatrix = gui.toggle("evenMatrix",evenMatrix);

	// NEW: Mirror Toggles
	mirrorHoriz = gui.toggle("Mirror Horizontal", mirrorHoriz);
	mirrorVert = gui.toggle("Mirror Vertical", mirrorVert);

	originOffset  = gui.plotXY("originOffset", width /2, height/2);
	scaleFactor  = gui.plotXY("scaleFactor", 150, 150);

	if (gui.button("resetValues")) {
		testPattern = 0;
		gui.sliderSet("testPattern", 0);

		matrixDensity = 27;
		gui.sliderSet("matrixDensity",27);

		radialSubdivision = 6;
		gui.sliderSet("radialSubdivision",6);

		Seed = 69420;
		gui.sliderSet("randomSeed",69420);

		originOffset.set(width/2,height/2);
		gui.plotSet("originOffset", width /2, height/2);

		scaleFactor.set(50,50);
		gui.plotSet("scaleFactor",150,150);

		evenMatrix = false;
		gui.toggleSet("evenMatrix", false);

		// Reset mirror toggles
		mirrorHoriz = false;
		gui.toggleSet("Mirror Horizontal", false);
		mirrorVert = false;
		gui.toggleSet("Mirror Vertical", false);

		compute = true;
		redraw = true;
	}

	if (gui.button("stop")) {
		exit();
	}

	if (gui.hasChanged("radialSubdivision") ||
			gui.hasChanged("scaleFactor") || 
			gui.hasChanged("matrixDensity") ||
			gui.hasChanged("randomSeed") ||
			gui.hasChanged("evenMatrix") ||
			gui.hasChanged("Mirror Horizontal") || // Trigger update on toggle
			gui.hasChanged("Mirror Vertical") ||   // Trigger update on toggle
			gui.hasChanged("originOffset") ||
			gui.hasChanged("testPattern")){

		compute = true;
		redraw = true;
		println("set compute and redraw flag");
			}
}

void draw(){
	//basic setup
	background(30);
	handleGui(gui);

	if (compute) {
		calculate();
	}

	if (redraw) {
		pg.beginDraw();
		pg.clear();
		// some draw logic
		pg.translate(originOffset.x, originOffset.y);
		pg.scale(1,-1);
		pg.strokeWeight(6);
		pg.noFill();
		pg.stroke(255,255,255);

		// draw stuffs
		for ( int i = 0; i < polygonVertices.size(); i++) {
			// draw shape
			point a = polygonVertices.get(i);
			point b = polygonVertices.get((i + 1) % polygonVertices.size());
			pg.stroke(100, 179, 100);
			pg.strokeWeight(2);
			pg.line(a.x, a.y, b.x, b.y);
			// show segments
			pg.stroke(100, 100, 200);
			pg.strokeWeight(1);
			pg.line(0, 0, b.x, b.y);
			// show vertices
			pg.stroke(0, 255, 0);
			pg.strokeWeight(7);
			pg.point(a.x, a.y);
		}

		//draw unitCells
		for(unitCell u : unitCells){
			drawCell(pg, u);
		}

		pg.endDraw();
		redraw = false;
		println("reset redraw flag");
	}

	image(pg,0,0);
	// image(pg,originOffset.x,originOffset.y);

	// draw gui 
	gui.draw();
}

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
	int patternMask;
	boolean rightConnection;
	boolean bottomConnection;

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

boolean containedIn(unitCell guidePoint, ArrayList<point> polygon){
	int count = 0;

	for (int i = 0; i < polygon.size(); i++) {
		point a = polygon.get(i);
		point b = polygon.get((i + 1) % polygon.size());

		// skip horizontal edges
		if (a.y == b.y) continue;

		if (isInBetween(guidePoint.y, a.y, b.y)) {
			point p = getIntersection(guidePoint, a, b);
			if (p.x > guidePoint.x) count++;
		}
	}

	return (count & 1) == 1;
}

// method to draw a pattern (might change this in the future)
void drawCell(PGraphics pg, unitCell center) {
	float dirtyFix = 2;
	switch (center.patternId) {
		case 0: pattern.Point(pg, center, matrixDensity/dirtyFix); break;
		case 1: pattern.circle(pg, center, matrixDensity/dirtyFix); break;
		case 2: pattern.connectedLeft(pg, center, matrixDensity/dirtyFix); break;
		case 3: pattern.connectedRight(pg, center, matrixDensity/dirtyFix); break;
		case 4: pattern.connectedUp(pg, center, matrixDensity/dirtyFix); break;
		case 5: pattern.connectedDown(pg, center, matrixDensity/dirtyFix); break;
		case 6: pattern.eyeHorizontal(pg, center, matrixDensity/dirtyFix); break;
		case 7: pattern.eyeVertical(pg, center, matrixDensity/dirtyFix); break;
		case 8: pattern.catEars_topLeft(pg, center, matrixDensity/dirtyFix); break;
		case 9: pattern.catEars_topRight(pg, center, matrixDensity/dirtyFix); break;
		case 10: pattern.catEars_bottomLeft(pg, center, matrixDensity/dirtyFix); break;
		case 11: pattern.catEars_bottomRight(pg, center, matrixDensity/dirtyFix); break;
		case 12: pattern.leftPizzaSlice(pg, center, matrixDensity/dirtyFix); break;
		case 13: pattern.rightPizzaSlice(pg, center, matrixDensity/dirtyFix); break;
		case 14: pattern.topPizzaSlice(pg, center, matrixDensity/dirtyFix); break;
		case 15: pattern.bottomPizzaSlice(pg, center, matrixDensity/dirtyFix); break;
		case 16: pattern.diamond(pg, center, matrixDensity/dirtyFix); break;
	}
}
