import com.krab.lazy.*;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Collections;
import java.util.List;


LazyGui gui;
PGraphics pg;

// =-=-=-=-=-=[ variables ]=-=-=-=-= //

int boundryValue = 300;
int winWidth = 600;
int winHeight = 600;
int pDensity = 1;
final point origin = new point(0,0);


// =-=-=-=-=-=[ boolean variables ]=-=-=-=-= //
volatile boolean compute = false;
volatile boolean redraw = false;

boolean evenMatrix = false;

boolean showPolygon = true;
boolean showSection = true;
boolean showPattern = false;
boolean showGuidePoints = false;
boolean showOrigin = true;

// =-=-=-=-=-=[ guiValuesSection ]=-=-=-=-= //
float testPattern = 1;
float matrixDensity = 27;
float radialSubdivision = 6;
float Seed = 69420;

PVector originOffset;
PVector scaleFactor;

// =-=-=-=-=-=[ Objects ]=-=-=-=-= //
pattern pattern = new pattern(4,255,255,255);
ArrayDeque<unitCell> stack =  new ArrayDeque<unitCell>();

ArrayList<point> polygonVertices =  new ArrayList<point>();
ArrayList<unitCell> unitCells = new ArrayList<unitCell>();

// ArrayList<unitCell> frameBuffer = new ArrayList<unitCell>();

// =-=-=-=-=-=[ Jobs ]=-=-=-=-= //
void setup(){
	// size(winWidth,winHeight,P2D);
	size(600,600,P2D);
	pixelDensity(pDensity);
	gui =  new LazyGui(this);
	pg = createGraphics(winWidth, winHeight, P2D);
	randomSeed(Seed);
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

	// step 2: Generate UnitCells
	unitCells.clear();
	unitCell start = evenMatrix ?  new unitCell(origin.x, origin.y, int(testPattern)) :
		new unitCell(origin.x + matrixDensity/2, origin.y + matrixDensity/2, int(testPattern));

	stack.push(start);

	while (!stack.isEmpty()) {
		unitCell curr = stack.pop();

		unitCells.add(curr);

		unitCell[] neighbours = {
			new unitCell(curr.x , curr.y + matrixDensity, int(testPattern)),
			new unitCell(curr.x + matrixDensity, curr.y , int(testPattern)),
			new unitCell(curr.x , curr.y - matrixDensity, int(testPattern)),
			new unitCell(curr.x - matrixDensity, curr.y , int(testPattern))
		};

		for (unitCell next : neighbours) {
			if (next.inBounds() && next.notIn(unitCells)) {
				if (containedIn(next,polygonVertices)) {
					stack.push(next);
				}
			}
		}
	}
	
	// step 3: Generate pattern
	
	// set the compute variable to false
	compute = false;
	println("reset compute flag");
}

boolean bitMasking(int bin, int mask){
	return (bin & mask) != 0;
}

void setPattern(unitCell u, int patternId){
	int rcl = 0b11110011001001000;
	int bcl = 0b11011001110100000;
	u.patternMask = 0b1 << patternId;
	u.rightConnection = bitMasking(rcl,u.patternMask);
	u.bottomConnection = bitMasking(bcl, u.patternMask);
	u.patternId = patternId;
}

int getRandomPattern(int bitList){
	Arraylist<Integer> ids = new Arraylist<Integer>();
	for (int i = 0; i < 18; i++) {
		if(((bitList >> i) & 1) == 1){
			ids.add(i);
		}
	}
}

// left has rc and top has bc ? as input
int getBitList(boolean rc, boolean bc){
	//bitlist to get pattern id
	if (rc & bc) {
		return 0b11010100000000000;
	} else if (!rc & bc){ 
		return 0b1010010010000;
	} else if (rc & !bc){
		return 0b100001001000100;
	} else if (!rc & !bc){
		return 0b100101011;
	}
}

void mirrorVertical(ArrayList<unitCell> array){
	int[] verticalSymmetry = {}
}

void mirrorHorizontal(ArrayList<unitCell> array){
	int[] horizontalSymmetry = {}
}

void patternGeneration(Arraylist<unitCells> array){
	int pattern;
		
	//sort the array and keep a single quardrant
	//after sorting
	for (int i = 0; i < array.size(); i++) {
		unitCelll cell = array.get(i);
		// logic to choose the bitlist
		
		// get value for pattern with getRandomPattern(bitlist)
		if (patterm == -1) {
			pattern = 0;
			println("invalid pattern id encountered")
		}
		setPattern(cell,pattern);
	}
}

void handleGui(LazyGui gui){
	testPattern = gui.slider("testPattern", testPattern, 0, 16);
	matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 200);
	radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);
	Seed  = gui.slider("randomSeed", Seed, 0, 99999);
	evenMatrix = gui.toggle("evenMatrix",evenMatrix);

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
		compute = true;
		redraw = true;
	}

	if (gui.button("stop")) {
		exit();
	}

	// calculate everytime a value changes using shared variable
	if (gui.hasChanged("radialSubdivision") ||
		gui.hasChanged("scaleFactor") || 
		gui.hasChanged("matrixDensity") ||
		gui.hasChanged("evenMatrix") ||
		gui.hasChanged("originOffset") ||
		gui.hasChanged("testPattern")){

		compute = true;
		redraw = true;
		println("set compute and reset flag");
	}
}

void draw(){
	//basic setup
	background(30);
	handleGui(gui);
	
	if (compute) {
		calculate();
	}
	
	// patternGenration logic here

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

// =-=-=-=-=-=[ helper methods ]=-=-=-=-= //

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
