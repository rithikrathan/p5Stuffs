import com.krab.lazy.*;
import java.util.Queue;
import java.util.LinkedList;
import java.util.Set;
import java.util.HashSet;

LazyGui gui;

float radialSubdivision  = 6;
float matrixDensity  = 27;
float testPattern  = 1;
PVector scaleFactor = new PVector(200, 200);
PVector originOffset;

//boolean variables
boolean evenMatrix = false;

// objec
ArrayList<point> polygonVertices = new ArrayList<point>();
ArrayList<point> guidePoints = new ArrayList<point>();

point origin =  new point(0, 0);
patterns pattern = new patterns();

// =-=-=-=-=-=[ classes ]=-=-=-=-= //

class point {
    float x, y;

    point(float x, float y) {
        this.x = x;
        this.y = y;
    }

    @Override
        public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof point)) return false;
        point p = (point) o;
        return x == p.x && y == p.y;
    }
}

// class unitCell extends point {
//     uniCell(float id, float y) {
//         this.x = x;
//         this.y = y;
//     }
// 	void draw(){}
// }

// =-=-=-=-=-=[ userInterface stuffs ]=-=-=-=-= //


void handleGui(LazyGui gui) {
    // lazy controls — created automatically first time run
    radialSubdivision = gui.slider("radialSubdivision", radialSubdivision, 0, 10);
    testPattern = gui.slider("testPattern", testPattern, 0, 16);
    matrixDensity = gui.slider("matrixDensity", matrixDensity, 0, 100);
    scaleFactor  = gui.plotXY("scaleFactor", scaleFactor.x, scaleFactor.y);
    originOffset  = gui.plotXY("originOffset", -width /2, -height/2);

    if (gui.button("resetValues")) {
        radialSubdivision  = 6;
        gui.sliderSet("radialSubdivision", 6);

        testPattern  = 3;
        gui.sliderSet("testPattern", 3);

        matrixDensity  = 27;
        gui.sliderSet("matrixDensity", 27);

        scaleFactor.set(200, 200);
        gui.plotSet("scaleFactor", 200, 200);

        originOffset.set(-width/2, -height/2);
        gui.plotSet("originOffset", -width/2, -height/2);

        // recalculate when reset
        polygonVertices.clear();
        polygonVertices = calculateShape(polygonVertices);

        guidePoints.clear();
        guidePoints = calculateGuidePoints(guidePoints, origin, evenMatrix);
    }

    if (gui.button("Quit")) {
        exit();
    }
}

// =-=-=-=-=-=[ some Calculation methods ]=-=-=-=-= //

ArrayList<point> calculateShape(ArrayList<point> pv) {
    // in python the arguments are references
    // idk if gp in the argument is the reference or not
    // if gp is a reference it will update the list, which i want
    // but idk if its a reference
    // so i create a list and return it
    ArrayList<point> polygonVertices = pv;	
    // calculate shape
    for (int i = 0; i < int(radialSubdivision); i++) {
        float theta = i * TAU / radialSubdivision;
        float x = scaleFactor.x * cos(theta);
        float y = scaleFactor.y * sin(theta);
        polygonVertices.add(new point(x, y));
    }
    return polygonVertices;
}


ArrayList<point> calculateGuidePoints(
    ArrayList<point> gp,
    point origin,
    boolean evenMatrix) {

    Queue<point> q = new LinkedList<>();
    Set<point> visited = new HashSet<>();

    point start = evenMatrix
        ? new point(origin.x + matrixDensity / 2, origin.y + matrixDensity / 2)
        : origin;

    q.add(start);
    visited.add(start);

    while (!q.isEmpty()) {
        point curr = q.poll();

        if (!containedIn(curr, polygonVertices)) continue;

        gp.add(curr);

        point[] neighbors = {
            new point(curr.x, curr.y + matrixDensity),
            new point(curr.x + matrixDensity, curr.y),
            new point(curr.x, curr.y - matrixDensity),
            new point(curr.x - matrixDensity, curr.y)
        };

        for (point p : neighbors) {
            if (!visited.contains(p) && containedIn(p, polygonVertices)) {
                visited.add(p);
                q.add(p);
            }
        }
    }
    return gp;
}

// =-=-=-=-=-=[ helpers ]=-=-=-=-= //

void drawPattern(point center, int id) {
    switch (id) {
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

// =-=-=-=-=-=[ raycasting to check if the point is in the polygon ]=-=-=-=-= //

boolean isInBetween(float y, float y1, float y2) {
    if (y1 > y2) {
        return y <= y1 && y > y2;
    } else {
        return y <= y2 && y > y1;
    }
}


point getIntersection(point point, point a, point b) {
    point pointOfIntersection = new point(a.x, point.y);
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

boolean containedIn(point point, ArrayList<point> polygon) {
    int count = 0;
    for (int i = 0; i < polygon.size(); i++) {
        point vert_a = polygon.get(i); //current point
        point vert_b = polygon.get((i+1) % polygon.size()); // next point

        if (vert_a.x != vert_b.x && isInBetween(point.y, vert_a.y, vert_b.y)) {
            point pointOfIntersection = getIntersection(point, vert_a, vert_b);
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

boolean notIn(point curr, ArrayList<point> points) {
    for (int i = 0; i < points.size(); i++) {
        if (points.get(i).equals(curr)) {
            return false;
        }
    }
    return true;
}

// =-=-=-=-=-=[ actual processing 4 stuffs ]=-=-=-=-= //

void setup() {
    size(600, 600, P2D);
    gui = new LazyGui(this); // init LazyGui

    //calculate with the initial values
    polygonVertices = calculateShape(polygonVertices);
    guidePoints = calculateGuidePoints(guidePoints, origin, evenMatrix);
}

void draw() {
    scale(-1, -1);
    background(30);
    handleGui(gui);
    translate(originOffset.x, originOffset.y); // set originOffset (0,0) to the middle of the screen

    // recalculate when values changes
    if (gui.hasChanged("radialSubdivision") || gui.hasChanged("scaleFactor") || gui.hasChanged("originOffset")) {
        polygonVertices.clear();
        polygonVertices = calculateShape(polygonVertices);
    }

    if (gui.hasChanged("matrixDensity")) {
        guidePoints.clear();
        guidePoints = calculateGuidePoints(guidePoints, origin, evenMatrix);
    }


    for (int i = 0; i < polygonVertices.size(); i++) {
        point vert_i = polygonVertices.get(i); //current point
        point vert_j = polygonVertices.get((i+1) % polygonVertices.size()); // next point

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

    stroke(255, 255, 255);
    strokeWeight(2);
    noFill();
    for (int i = 0; i < guidePoints.size(); i++) {
        point curr = guidePoints.get(i);
        drawPattern(curr, int(testPattern));
    }

    gui.draw(); // draw the GUI
}
