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

// Mirroring Toggles
boolean mirrorHoriz = false;
boolean mirrorVert = false;

float testPattern = 1;
float matrixDensity = 27;
float radialSubdivision = 6;
float Seed = 69420;

// Priority Weights for the 17 patterns (0-16)
int[] patternWeights = new int[17];

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
    // Note: randomSeed is now called inside calculate()
}

void calculate(){
    // FIX: Reset seed here so patterns are consistent every calculation
    randomSeed((long) Seed);

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
        for (int y = -int(matrixDensity); y > -boundryValue; y -= matrixDensity) {
            int currCount = 0; 
            for (int x = int(matrixDensity); x < boundryValue; x += matrixDensity) {
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

    // Apply mirroring logic
    applyMirroring();

    compute = false;
    println("reset compute flag");
}

void applyMirroring() {
    int[] vMirrorImages = {0,1,2,3,5,4,6,7,10,11,8,9,12,13,15,14,16};
    int[] hMirrorImages = {0,1,3,2,4,5,6,7,9,8,11,10,13,12,14,15,16};

    // 1. Mirror Horizontally (Right -> Left)
    if (mirrorHoriz) {
        int currentSize = unitCells.size();
        for (int i = 0; i < currentSize; i++) {
            unitCell u = unitCells.get(i);
            if (u.x != 0) {
                unitCell m = new unitCell(-u.x, u.y, hMirrorImages[u.patternId]);
                setPattern(m); 
                unitCells.add(m);
            }
        }
    }

    // 2. Mirror Vertically (Bottom -> Top)
    if (mirrorVert) {
        int currentSize = unitCells.size();
        for (int i = 0; i < currentSize; i++) {
            unitCell u = unitCells.get(i);
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

// NEW: Weighted Random Pattern Selection
int getRandomPattern(int bitList){
    ArrayList<Integer> validCandidates = new ArrayList<Integer>();
    
    // 1. Find which patterns fit the neighbors
    for (int i = 0; i < 17; i++) {
        if(((bitList >> i) & 1) == 1){
            validCandidates.add(i);
        }
    }

    if (validCandidates.size() == 0) return -1; 

    // 2. Calculate Total Weight of VALID candidates
    int totalWeight = 0;
    for (int id : validCandidates) {
        totalWeight += patternWeights[id];
    }

    // Edge case: If all valid weights are 0, pick randomly
    if (totalWeight == 0) {
        return validCandidates.get((int)random(validCandidates.size()));
    }

    // 3. Weighted Random Selection
    float randomValue = random(totalWeight);

    for (int id : validCandidates) {
        randomValue -= patternWeights[id];
        if (randomValue <= 0) {
            return id;
        }
    }
    
    return validCandidates.get(0);
}

// left has rc and top has bc ? as input
int getBitList(ArrayList<unitCell> array, int prevCount){

    boolean rc = random(1) > 0.5;
    boolean bc = random(1) > 0.5;

    if (array.size() > 0) {
        rc = array.get(array.size() - 1).rightConnection;
    }

    if (prevCount > 0 && array.size() >= prevCount) {
        bc = array.get(array.size() - prevCount).bottomConnection;
    }

    if (rc & bc) {
        return 0b10101100000000000; //lcitc
    } else if (!rc & bc){ 
        return 0b10010010010000; //nlcitc
    } else if (rc & !bc){
        return 0b1000001001000100; //lcintc
    } else {
        return 0b00100010; //nlcintc
    }
}

void handleGui(LazyGui gui){
    testPattern = gui.slider("testPattern", testPattern, 0, 16);
    matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 200);
    radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);
    Seed  = gui.slider("randomSeed", Seed, 0, 99999);
    evenMatrix = gui.toggle("evenMatrix",evenMatrix);

    mirrorHoriz = gui.toggle("Mirror Horizontal", mirrorHoriz);
    mirrorVert = gui.toggle("Mirror Vertical", mirrorVert);

    originOffset  = gui.plotXY("originOffset", width /2, height/2);
    scaleFactor  = gui.plotXY("scaleFactor", 150, 150);

    // --- WEIGHTS FOLDER ---
    gui.pushFolder("Pattern Weights");
    boolean weightsChanged = false;
    for(int i=0; i<17; i++){
        // Default weight is 5, Range is 0 to 10
        String pName = "Pattern " + i;
        patternWeights[i] = gui.sliderInt(pName, 5, 0, 10);
        
        if(gui.hasChanged("Pattern Weights/" + pName)){
            weightsChanged = true;
        }
    }
    gui.popFolder();
    // ----------------------

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
        mirrorHoriz = false;
        gui.toggleSet("Mirror Horizontal", false);
        mirrorVert = false;
        gui.toggleSet("Mirror Vertical", false);
        
        // Reset weights
        for(int i=0; i<17; i++) gui.sliderSet("Pattern Weights/Pattern " + i, 5);

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
        gui.hasChanged("Mirror Horizontal") || 
        gui.hasChanged("Mirror Vertical") ||   
        gui.hasChanged("originOffset") ||
        gui.hasChanged("testPattern") ||
        weightsChanged){ 

        compute = true;
        redraw = true;
        println("set compute and redraw flag");
    }
}

void draw(){
    background(30);
    handleGui(gui);

    if (compute) {
        calculate();
    }

    if (redraw) {
        pg.beginDraw();
        pg.clear();
        pg.translate(originOffset.x, originOffset.y);
        pg.scale(1,-1);
        pg.strokeWeight(6);
        pg.noFill();
        pg.stroke(255,255,255);

        // draw shape
        for ( int i = 0; i < polygonVertices.size(); i++) {
            point a = polygonVertices.get(i);
            point b = polygonVertices.get((i + 1) % polygonVertices.size());
            pg.stroke(100, 179, 100);
            pg.strokeWeight(2);
            pg.line(a.x, a.y, b.x, b.y);
            
            pg.stroke(100, 100, 200);
            pg.strokeWeight(1);
            pg.line(0, 0, b.x, b.y);
            
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
    
    public boolean inBounds() {
        return this.x >= -boundryValue && this.x <= boundryValue &&
               this.y >= -boundryValue && this.y <= boundryValue;
    }
}

boolean isInBetween(float y, float y1, float y2){
    return (y > min(y1, y2)) && (y <= max(y1, y2));
}

point getIntersection(unitCell rayPoint, point a, point b){
    float x = a.x + (rayPoint.y - a.y) * (b.x - a.x) / (b.y - a.y);
    return new point(x, rayPoint.y);
}

boolean containedIn(unitCell guidePoint, ArrayList<point> polygon){
    int count = 0;
    for (int i = 0; i < polygon.size(); i++) {
        point a = polygon.get(i);
        point b = polygon.get((i + 1) % polygon.size());

        if (a.y == b.y) continue;

        if (isInBetween(guidePoint.y, a.y, b.y)) {
            point p = getIntersection(guidePoint, a, b);
            if (p.x > guidePoint.x) count++;
        }
    }
    return (count & 1) == 1;
}

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
