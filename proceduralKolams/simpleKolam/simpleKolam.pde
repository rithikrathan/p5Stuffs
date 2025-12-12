import com.krab.lazy.*;

LazyGui gui;

float radialSubdivision  = 6;
float matrixDensity  = 27;
PVector scaleFactor = new PVector(200, 200);
PVector origin;

//boolean variables
boolean evenMatrix = false;

ArrayList<vertex> polygonVertices = new ArrayList<vertex>();
ArrayList<vertex> guidePoints = new ArrayList<vertex>();

class vertex {
    float x, y;
    vertex(float x, float y) {
        this.x = x;
        this.y = y;
    }
}


void handleGui(LazyGui gui) {
    // lazy controls — created automatically first time run
    radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);
    matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 100);
    scaleFactor  = gui.plotXY("scaleFactor", scaleFactor.x, scaleFactor.y);
    origin  = gui.plotXY("origin", width /2, height/2);

    if (gui.button("resetValues")) {
        radialSubdivision  = 6;
        gui.sliderSet("radialSubdivision", 6);

        matrixDensity  = 27;
        gui.sliderSet("matrixDensity", 27);

        scaleFactor.set(200, 200);
        gui.plotSet("scaleFactor", 200, 200);

        origin.set(width/2, height/2);
        gui.plotSet("origin", width/2, height/2);

        // recalculate when reset
        polygonVertices.clear();
        polygonVertices = calculateShape(polygonVertices);

        guidePoints.clear();
        guidePoints = calculateGuidePoints(guidePoints, evenMatrix);
    }

    if (gui.button("Quit")) {
        exit();
    }
}

ArrayList<vertex> calculateShape(ArrayList<vertex> pv) {
    ArrayList<vertex> polygonVertices = pv;	
    // calculate shape
    for (int i = 0; i < int(radialSubdivision); i++) {
        float theta = i * TAU / radialSubdivision;
        float x = scaleFactor.x * cos(theta);
        float y = scaleFactor.y * sin(theta);
        polygonVertices.add(new vertex(x, y));
    }
    return polygonVertices;
}

ArrayList<vertex> calculateGuidePoints(ArrayList<vertex> gp, boolean evenMatix) {
    ArrayList<vertex> guidePoints = gp;	
    // calculate guidePoints

    return guidePoints;
}

boolean isInBetween(float y, float y1, float y2) {
    if (y1 > y2) {
        return y <= y1 && y > y2;
    } else {
        return y <= y2 && y > y1;
    }
}


vertex getIntersection(vertex point, vertex a, vertex b) {
    vertex pointOfIntersection = new vertex(a.x,point.y);
    try {
        float slope = (b.y - a.y)/(b.x -a.x);
        pointOfIntersection.y = point.y;
        pointOfIntersection.x = ((pointOfIntersection.y - a.y)/slope)+a.x;
        return pointOfIntersection;
    }
    catch (ArithmeticException e) {
		System.out.println("encountered arithmetic exception");
        return pointOfIntersection;
    }
}

boolean containedIn(vertex point, ArrayList<vertex> polygon) {
    int count = 0;
    for (int i = 0; i < polygonVertices.size(); i++) {
        vertex vert_a = polygonVertices.get(i); //current vertex
        vertex vert_b = polygonVertices.get((i+1) % polygonVertices.size()); // next vertex

        if (vert_a.x != vert_b.x && isInBetween(point.y, vert_a.y, vert_b.y)) {
            vertex pointOfIntersection = getIntersection(point, vert_a, vert_b);
            if (pointOfIntersection.x > point.x) {
                count ++;
            }
        }
    }

    if (count % 2 == 0) {
        return false;
    }

    return true;
}

void setup() {
    size(600, 600, P2D);
    gui = new LazyGui(this); // init LazyGui

    //calculate with the initial values
    polygonVertices = calculateShape(polygonVertices);
    guidePoints = calculateGuidePoints(guidePoints, evenMatrix);
}

void draw() {
    background(30);
    handleGui(gui);
    translate(origin.x, origin.y); // set origin (0,0) to the middle of the screen

    // recalculate when values changes
    if (gui.hasChanged("radialSubdivision") || gui.hasChanged("scaleFactor") || gui.hasChanged("origin")) {
        polygonVertices.clear();
        polygonVertices = calculateShape(polygonVertices);
    }

    if (gui.hasChanged("matrixDensity")) {
        guidePoints.clear();
        guidePoints = calculateGuidePoints(guidePoints, evenMatrix);
    }


    for (int i = 0; i < polygonVertices.size(); i++) {
        vertex vert_i = polygonVertices.get(i); //current vertex
        vertex vert_j = polygonVertices.get((i+1) % polygonVertices.size()); // next vertex

        // show edges
        stroke(100, 179, 100);
        strokeWeight(2);
        line(vert_i.x, vert_i.y, vert_j.x, vert_j.y);

        // show segments
        stroke(100, 100, 200);
        strokeWeight(1);
        line(0, 0, vert_j.x, vert_j.y);

        // show vertices
        stroke(0, 255, 0);
        strokeWeight(7);
        point(vert_i.x, vert_i.y);
    }

    // draw logic
    stroke(255, 0, 0);
    strokeWeight(5);
    point(0, 0); // mark origin

    gui.draw(); // draw the GUI
}
