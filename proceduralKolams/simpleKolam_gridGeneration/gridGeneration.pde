import com.krab.lazy.*;
import java.util.ArrayDeque;
import java.util.ArrayList;

// =-=-=-=-=-=[ SETUP OPTIONS ]=-=-=-=-= //
int PIXEL_DENSITY = 1;  
int TARGET_FPS = 60;    

// =-=-=-=-=-=[ Objects ]=-=-=-=-= //
LazyGui gui;
ArrayDeque<unitCell> stack = new ArrayDeque<unitCell>();
ArrayList<unitCell> visitedCells = new ArrayList<unitCell>();
ArrayList<unitCell> rejectedCells = new ArrayList<unitCell>(); 
ArrayList<point> polygonVertices = new ArrayList<point>();

// =-=-=-=-=-=[ State ]=-=-=-=-= //
boolean isFinished = false;
boolean isPaused = false;
unitCell currentActive = null;
PVector cameraOffset = new PVector(0,0);

void setup() {
  size(600, 600, P2D);
  pixelDensity(PIXEL_DENSITY);
  frameRate(TARGET_FPS);
  
  gui = new LazyGui(this);
  resetSimulation(); 
}

void draw() {
  background(gui.colorPicker("visuals/background", color(30)).hex);
  
  // 1. Polygon Controls
  int sides = gui.sliderInt("polygon/sides", 6, 3, 12);
  float radius = gui.slider("polygon/radius", 250, 50, 400);
  
  // 2. The Important Sliders
  // "Spacing": The actual distance between coordinates (The math)
  float gridSpacing = gui.slider("grid/spacing (distance)", 40, 10, 100);
  
  // "Dot Size": The visual size of the dot (The drawing)
  // This is now independent. Changing spacing won't make dots bigger.
  float dotSizePx = gui.slider("visuals/dot size (px)", 15, 2, 50);
  
  int speed = gui.sliderInt("simulation/delay frames", 5, 1, 60);
  
  // 3. Other Visuals
  boolean showLines = gui.toggle("visuals/show connections", true);
  float lineThick = gui.slider("visuals/line thickness", 1.5, 0.5, 5.0);
  
  // 4. Recording
  boolean isRecording = gui.toggle("recording/record frames", false);
  
  // Camera Pan
  if(mousePressed && mouseButton == RIGHT){
      cameraOffset.x += mouseX - pmouseX;
      cameraOffset.y += mouseY - pmouseY;
  }
  
  // AUTO-RESET: Only reset if the Math changes (Shape or Spacing)
  // Changing dotSizePx does NOT reset the sim.
  if(gui.hasChanged("polygon/sides") || 
     gui.hasChanged("polygon/radius") || 
     gui.hasChanged("grid/spacing (distance)")) {
     generatePolygon(sides, radius);
     resetSimulation();
  }

  // LOGIC
  if (!isFinished && !isPaused && frameCount % speed == 0) {
    stepAlgorithm(gridSpacing);
  }

  // RENDER
  pushMatrix(); 
  translate(width/2 + cameraOffset.x, height/2 + cameraOffset.y);

  // A. Draw Polygon
  stroke(gui.colorPicker("visuals/polygon color", color(100, 255, 100)).hex);
  strokeWeight(3);
  noFill();
  beginShape();
  for (point p : polygonVertices) vertex(p.x, p.y);
  endShape(CLOSE);

  // B. Draw REJECTED Points (Violet)
  int rejectedColor = gui.colorPicker("visuals/dots rejected", color(180, 50, 255)).hex;
  // We pass 'dotSizePx' directly now
  drawCellGroup(rejectedCells, rejectedColor, dotSizePx * 0.7, showLines, lineThick);

  // C. Draw FINISHED Points (White)
  int visitedColor = gui.colorPicker("visuals/dots finished", color(255)).hex;
  drawCellGroup(visitedCells, visitedColor, dotSizePx, showLines, lineThick);

  // D. Draw STACK Points (Blue)
  fill(gui.colorPicker("visuals/dots frontier", color(0, 100, 255)).hex);
  noStroke();
  for (unitCell u : stack) {
     float size = dotSizePx * 0.5; 
     ellipse(u.x, u.y, size, size);
  }

  // E. Draw ACTIVE Point (Red)
  if (currentActive != null) {
    fill(gui.colorPicker("visuals/dots active", color(255, 0, 100)).hex);
    float activeSize = dotSizePx * 1.2;
    ellipse(currentActive.x, currentActive.y, activeSize, activeSize);
    
    // Radar ping
    noFill();
    stroke(255, 0, 100, 100);
    strokeWeight(1);
    ellipse(currentActive.x, currentActive.y, activeSize*1.8, activeSize*1.8);
  }
  
  popMatrix(); 

  // Overlays
  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("FPS: " + int(frameRate), 10, height - 30);
  if(isPaused) text("PAUSED (Space)", 10, height - 50);
  if(isRecording) {
      fill(255, 0, 0);
      text("REC", width - 40, height - 30);
      saveFrame("output/frame_####.png"); 
  }
}

// =-=-=-=[ LOGIC CORE ]=-=-=-= //

void stepAlgorithm(float spacing) {
  if (stack.isEmpty()) {
    isFinished = true;
    return;
  }

  unitCell curr = stack.pop();
  currentActive = curr; 
  visitedCells.add(curr);

  // Spacing controls MATH distance
  unitCell[] neighbors = {
      new unitCell(curr.x, curr.y + spacing, curr),
      new unitCell(curr.x + spacing, curr.y, curr),
      new unitCell(curr.x, curr.y - spacing, curr),
      new unitCell(curr.x - spacing, curr.y, curr)
  };

  for (unitCell next : neighbors) {
     if (abs(next.x) < 2000 && abs(next.y) < 2000) { 
        if (next.notIn(visitedCells) && next.notInDeque(stack) && next.notIn(rejectedCells)) {
           if (containedIn(next, polygonVertices)) {
              stack.push(next); 
           } else {
              rejectedCells.add(next); 
           }
        }
     }
  }
}

// Updated Helper: Uses absolute pixel size
void drawCellGroup(ArrayList<unitCell> group, int col, float pixelSize, boolean showLines, float lineThick) {
  for (unitCell u : group) {
    if (u.animScale < 1.0) u.animScale = lerp(u.animScale, 1.0, 0.15);
    
    if (showLines && u.parent != null) {
        stroke(255, 60);
        strokeWeight(lineThick);
        line(u.x, u.y, u.parent.x, u.parent.y);
    }
    
    noStroke();
    fill(col);
    // Size is purely visual now
    float size = pixelSize * u.animScale; 
    ellipse(u.x, u.y, size, size);
  }
}

void generatePolygon(int sides, float radius) {
  polygonVertices.clear();
  for (int i = 0; i < sides; i++) {
    float theta = i * TAU / sides;
    polygonVertices.add(new point(radius * cos(theta - HALF_PI), radius * sin(theta - HALF_PI)));
  }
}

void resetSimulation() {
  stack.clear();
  visitedCells.clear();
  rejectedCells.clear();
  isFinished = false;
  currentActive = null;
  stack.push(new unitCell(0, 0, null));
  if(polygonVertices.isEmpty()) generatePolygon(6, 200);
}

void keyPressed() {
  if (key == ' ') isPaused = !isPaused;
  if (key == ENTER || key == RETURN) resetSimulation();
}

// =-=-=-=[ CLASSES & MATH ]=-=-=-= //

class point {
  float x, y;
  point(float x, float y) { this.x = x; this.y = y; }
}

class unitCell extends point {
  unitCell parent; 
  float animScale = 0; 

  unitCell(float x, float y, unitCell parent) { 
    super(x, y); 
    this.parent = parent;
  }

  boolean notIn(ArrayList<unitCell> list) {
    for (unitCell u : list) {
      if (dist(u.x, u.y, x, y) < 1) return false;
    }
    return true;
  }
  
  boolean notInDeque(ArrayDeque<unitCell> deque) {
    for (unitCell u : deque) {
      if (dist(u.x, u.y, x, y) < 1) return false;
    }
    return true;
  }
}

boolean isInBetween(float y, float y1, float y2) {
  return (y > min(y1, y2)) && (y <= max(y1, y2));
}

point getIntersection(unitCell rayPoint, point a, point b) {
  float x = a.x + (rayPoint.y - a.y) * (b.x - a.x) / (b.y - a.y);
  return new point(x, rayPoint.y);
}

boolean containedIn(unitCell guidePoint, ArrayList<point> polygon) {
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
