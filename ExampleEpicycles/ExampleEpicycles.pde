// --- GLOBAL VARIABLES ---
int step = 0;          
int maxSteps = 4;      

// Math & Motion
float r1 = 150;        
float r2;              // Will be r1/2
float speed = 1.0;     // Speed of time evolution
float time = 0;        // Global time tracker

// --- NEW: PHASE & FREQUENCY VARIABLES ---
float freq1 = 1.0;     
float freq2 = 2.0;     // Try 2.0 to see them rotate differently!
float initPhase1 = 30; // Initial angle for Circle 1 (Degrees)
float initPhase2 = 90; // Initial angle for Circle 2 (Degrees)

boolean isAnimating = false;
boolean showArc = true; 

// Path Tracing
ArrayList<PVector> trace = new ArrayList<PVector>();

// Colors
color bgCol = color(10, 10, 50);
color axisCol = color(80, 80, 100); 
color textCol = color(255, 255, 200); 
color pointCol = color(255, 100, 100); 
color line1Col = color(0, 255, 255);   // Cyan
color line2Col = color(255, 0, 255);   // Magenta 
color arcCol = color(255, 200, 0);   

void setup() {
  size(800, 600);
  r2 = r1 / 2; 
  
  textSize(16);
  textAlign(CENTER, CENTER); 
}

void draw() {
  background(bgCol); 
  translate(width/2, height/2); 

  // --- ANIMATION LOGIC ---
  if (isAnimating) {
    time += speed;
    
    // Step 3 Limit: Stop after one full rotation of Circle 1
    // One rotation happens when time * freq1 reaches 360
    if (step == 3) {
      if (time * freq1 >= 360) {
        time = 0; // Reset for cleanliness
        isAnimating = false;
        showArc = false; 
      }
    }
    // Step 4: Loop forever
    else if (step == 4) {
      // No limits
    }
  }

  // --- DRAWING ---
  
  // 1. Static Origin
  if (step >= 1) {
    drawPoint(0, 0, "(0,0)", textCol);
  }

  // 2. Axes
  if (step >= 2) {
    drawAxes();
  }

  // 3. First Vector R1
  if (step >= 2) {
    // Calculate Angle 1: (Time * Freq) + Initial Offset
    float theta1Deg = (time * freq1) + initPhase1;
    float theta1 = radians(theta1Deg);
    
    float x1 = r1 * cos(theta1);
    float y1 = -r1 * sin(theta1); // Negative Y for screen

    // Draw R1 Path
    noFill(); stroke(255, 30); strokeWeight(1);
    ellipse(0, 0, r1*2, r1*2);

    // Draw R1 Line
    stroke(line1Col); strokeWeight(3);
    line(0, 0, x1, y1);
    
    fill(line1Col); textSize(14);
    text("R1", x1/2, y1/2 - 15);

    // Draw Arc (Step 2 & 3 only)
    if (step <= 3 && showArc) {
      drawAngleArc(theta1, initPhase1); // Pass initPhase for visual alignment
    }

    // --- SECOND VECTOR R2 (Step 4 only) ---
    if (step >= 4) {
      // Calculate Angle 2: (Time * Freq) + Initial Offset
      float theta2Deg = (time * freq2) + initPhase2;
      float theta2 = radians(theta2Deg);
      
      // Calculate Tip of R2 (Relative to Tip of R1)
      float x2 = x1 + r2 * cos(theta2);
      float y2 = y1 - r2 * sin(theta2);

      // Draw R2 Path (Centered at Tip of R1)
      noFill(); stroke(255, 30); strokeWeight(1);
      ellipse(x1, y1, r2*2, r2*2);

      // Draw R2 Line
      stroke(line2Col); strokeWeight(3);
      line(x1, y1, x2, y2);

      fill(line2Col);
      text("R2", (x1+x2)/2, (y1+y2)/2 - 15);

      // Draw End Point
      drawPoint(x2, y2, "", pointCol);

      // Trace Path
      if (isAnimating) {
        trace.add(new PVector(x2, y2));
        if (trace.size() > 1000) trace.remove(0); // Keep trace manageable
      }
      drawTrace();

    } else {
      // Not at Step 4? Just draw point at R1 tip
      drawPoint(x1, y1, "", pointCol);
    }
  }
}

// --- HELPERS ---

void drawAxes() {
  stroke(axisCol); strokeWeight(1);
  line(-width/2, 0, width/2, 0);
  line(0, -height/2, 0, height/2);
}

void drawAngleArc(float currentThetaRad, float startPhaseDeg) {
  noFill(); stroke(arcCol); strokeWeight(2);
  float arcSize = 60;
  
  // Visualizing the arc is tricky when rotating. 
  // We draw from 0 (xaxis) to the current angle.
  // Note: -currentThetaRad because Processing Y is flipped.
  arc(0, 0, arcSize, arcSize, -currentThetaRad, 0); 
  
  fill(arcCol); 
  float labelDist = 50;
  // Convert current angle back to degrees for display
  int dispAngle = int(degrees(currentThetaRad) % 360);
  if (dispAngle < 0) dispAngle += 360;
  
  text(dispAngle + "°", labelDist * cos(-currentThetaRad/2), labelDist * sin(-currentThetaRad/2));
}

void drawPoint(float x, float y, String label, color c) {
  stroke(c); strokeWeight(8);
  point(x, y);
  if (label.length() > 0) {
    fill(textCol); textAlign(LEFT, TOP);
    text(label, x + 10, y + 10);
  }
}

void drawTrace() {
  noFill(); stroke(pointCol); strokeWeight(2);
  beginShape();
  for (PVector v : trace) {
    vertex(v.x, v.y);
  }
  endShape();
}

// --- CONTROLS ---
void keyPressed() {
  if (keyCode == RIGHT) {
    if (step < maxSteps) {
      step++;
      trace.clear();
      time = 0; // Always reset time on step change for clean states
      
      if (step == 3) { 
        isAnimating = true; 
        showArc = true; 
      }
      if (step == 4) { 
        isAnimating = true; 
        showArc = false; 
      }
    }
  } else if (keyCode == LEFT) {
    if (step > 0) {
      step--;
      trace.clear();
      time = 0; 
      
      if (step < 3) {
        isAnimating = false;
        showArc = true;
      }
    }
  }
}
