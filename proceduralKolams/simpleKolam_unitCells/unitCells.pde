import com.krab.lazy.*;

LazyGui gui;

// =-=-=-=-=-=[ variables ]=-=-=-=-= //
final point origin = new point(0,0);

// =-=-=-=-=-=[ ciriticalSection ]=-=-=-=-= //
PVector originOffset;
float patternIdSliderValue; // Renamed to avoid confusion with active indices
float matrixDensity = 145;

// =-=-=-=-=-=[ Animation State Variables ]=-=-=-=-= //
boolean isLooping = false;
int currentPatternIdx = 0;
int nextPatternIdx = 1;
int totalPatterns = 17;

// Timing and Transition variables
long lastTime;
float transitionProgress = 0.0; // 0.0 = static current, >0.0 = transitioning to next
int state = 0; // 0 = STATIC, 1 = TRANSITIONING
int durationStatic = 1500; // Time to stay on one pattern (ms)
int durationMorph = 1000;   // Time to morph between patterns (ms)

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
    lastTime = millis();
    
    // Initialize GUI values to match code defaults
    gui.sliderSet("Duration (ms)", durationStatic);
    gui.sliderSet("Morph Time (ms)", durationMorph);
}


void handleGui(LazyGui gui){
    // Move main controls to a folder for cleaner UI
    gui.pushFolder("Controls");
    
    isLooping = gui.toggle("Auto Loop Mode", isLooping);
    
    // Only enable the slider if NOT looping, to prevent fighting
    if(!isLooping){
       patternIdSliderValue = gui.slider("Manual Pattern ID", patternIdSliderValue, 0, totalPatterns - 1);
    } else {
       // Update the slider visually to show progress, but disable input
       gui.sliderSet("Manual Pattern ID", currentPatternIdx);
       
       // FIX: Use standard Processing text() to draw on the screen
       // NOT gui.text()
       pushStyle();
       fill(255);
       textSize(14);
       text("Looping active...", 10, 20);
       popStyle();
    }
    
    durationStatic = gui.sliderInt("Duration (ms)", durationStatic, 500, 5000);
    durationMorph = gui.sliderInt("Morph Time (ms)", durationMorph, 100, 3000);
    
    originOffset  = gui.plotXY("Origin Offset", width /2, height/2);
    matrixDensity = gui.slider("Matrix Density", matrixDensity, 50, 300);

    if (gui.button("Reset Values")) {
        patternIdSliderValue = 0;
        gui.sliderSet("Manual Pattern ID", 0);
        currentPatternIdx = 0;
        nextPatternIdx = 1;
        state = 0;
        transitionProgress = 0;
        originOffset.set(width/2,height/2);
        gui.plotSet("Origin Offset", width /2, height/2);
        isLooping = false;
        gui.toggleSet("Auto Loop Mode", false);
    }
    
    gui.popFolder();

    if (gui.button("stop")) {
        exit();
    }
}

void updateAnimationState() {
  long currentTime = millis();
  long deltaTime = currentTime - lastTime;

  if (isLooping) {
    if (state == 0) { // STATIC STATE
      transitionProgress = 0.0;
      if (deltaTime > durationStatic) {
        state = 1; // Start transitioning
        lastTime = currentTime;
      }
    } else if (state == 1) { // TRANSITIONING STATE
      transitionProgress = (float)deltaTime / (float)durationMorph;
      
      if (deltaTime >= durationMorph) {
        // Transition finished
        state = 0; // Back to static
        currentPatternIdx = nextPatternIdx;
        nextPatternIdx = (currentPatternIdx + 1) % totalPatterns;
        lastTime = currentTime;
        transitionProgress = 0.0;
      }
    }
  } else {
    // Manual Mode: just set current index from slider
    state = 0;
    transitionProgress = 0.0;
    currentPatternIdx = int(patternIdSliderValue);
    lastTime = currentTime; // reset timer so looping starts freshly if re-enabled
  }
}

void draw(){
    //basic setup
    background(10); // Clear background for animation
    
    handleGui(gui);
    updateAnimationState();
    
    pushMatrix(); // Save default coord system for GUI later
    translate(originOffset.x,originOffset.y); // set the origin to the middle of the screen
    scale(1,-1);

    // draw static boundary polygon
    drawBoundary();

    // Draw the animated patterns
    stroke(255,255,255);
    // We don't set weight here anymore, we rely on the pattern class or blend logic
    drawBlendedPatterns(origin);

    popMatrix(); // Restore coords for GUI

    // draw gui 
    gui.draw();
}

void drawBoundary(){
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

// This function handles the blending logic based on animation state
void drawBlendedPatterns(point center) {
  if (transitionProgress <= 0.001) {
    // Static mode: Just draw the current pattern at full strength (1.0)
    callPatternMethod(currentPatternIdx, center, 1.0);
  } else {
    // Transition mode: Draw BOTH.
    
    // 1. Draw the 'old' pattern fading OUT (strength goes from 1.0 down to 0.0)
    float outgoingStrength = map(transitionProgress, 0.0, 1.0, 1.0, 0.0);
    callPatternMethod(currentPatternIdx, center, outgoingStrength);

    // 2. Draw the 'new' pattern fading IN (strength goes from 0.0 up to 1.0)
    float incomingStrength = map(transitionProgress, 0.0, 1.0, 0.0, 1.0);
    callPatternMethod(nextPatternIdx, center, incomingStrength);
  }
}


// Helper to call the specific pattern method based on index.
// 'blendFactor' (0.0 to 1.0) controls the "warp" effect by scaling density.
void callPatternMethod(int idx, point center, float blendFactor) {
    
    // The "Warp" Effect:
    // Instead of using the fixed matrixDensity, we scale it by the blendFactor.
    // When blendFactor is 1.0, it looks normal. When 0.0, it shrinks to a point.
    float warpedDensity = matrixDensity * blendFactor;
    
    // Optional tweak: Adjust stroke weight too so it doesn't get too clunky when small
    // Assuming base weight is around 10 from your original code
    strokeWeight(max(1, 10 * blendFactor)); 

    switch (idx) {
		case 0: pattern.Point( center, matrixDensity); break;
		case 1: pattern.circle( center, matrixDensity); break;
		case 2: pattern.connectedLeft( center, matrixDensity); break;
		case 3: pattern.connectedRight( center, matrixDensity); break;
		case 4: pattern.connectedUp( center, matrixDensity); break;
		case 5: pattern.connectedDown( center, matrixDensity); break;
		case 6: pattern.eyeHorizontal( center, matrixDensity); break;
		case 7: pattern.eyeVertical( center, matrixDensity); break;
		case 8: pattern.catEars_topLeft( center, matrixDensity); break;
		case 9: pattern.catEars_topRight( center, matrixDensity); break;
		case 10: pattern.catEars_bottomLeft( center, matrixDensity); break;
		case 11: pattern.catEars_bottomRight( center, matrixDensity); break;
		case 12: pattern.leftPizzaSlice( center, matrixDensity); break;
		case 13: pattern.rightPizzaSlice( center, matrixDensity); break;
		case 14: pattern.topPizzaSlice( center, matrixDensity); break;
		case 15: pattern.bottomPizzaSlice( center, matrixDensity); break;
		case 16: pattern.diamond( center, matrixDensity); break;
        default: break;
    }
}
