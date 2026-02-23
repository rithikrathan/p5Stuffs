import com.krab.lazy.LazyGui;

LazyGui gui;
float radius = 100;
boolean export = false;
boolean playing = false;
float thetaMain;
float thetaFrom;
float thetaTo;
float time = 0;
float dt = 0.005; // increased default speed slightly

class Point {
    float x, y;
    color col;

    Point(float x, float y, color col) {
        this.x = x;
        this.y = y;
        this.col = col;
    }

    // x′ = xcos(θ) − ysin(θ)
    // y′ = xsin(θ) + ycos(θ)

    void rotate(float theta) {
        float a = sin(theta);
        float b = cos(theta);

        float prev_x = this.x; // temp

        this.x = prev_x * b - this.y * a;
        this.y = prev_x * a + this.y * b;
    }

}

class Complex extends Point {
    Complex(float re, float im, color col) {
        super(re,im,col);
    }
    // rotation using complex representation
    // (x+iy) * e^iθ = (x+iy)(cosθ+isinθ)

    // x′ = Re((x+iy)(cosθ+isinθ)) = xcosθ − ysinθ
    // y′= Im((x+iy)(cosθ+isinθ)) = xsinθ + ycosθ

    void rotate(float theta){
        multiply(new Complex(cos(theta),sin(theta),#000000));
    }

    float getPhase(){
         return atan2(this.y, this.x); // angle
    }

    void add(Complex c){ this.x += c.x; this.y += c.y;}

    void multiply(Complex c){
        float tempRe = this.x;
        this.x= (tempRe * c.x) - (this.y* c.y);
        this.y= (tempRe * c.y) + (c.x* this.y);
    }

}

// Point pt = new Point(radius,0, #4dccb3);
// Point ptt = new Point(radius,0, #f24447);
// Point ptf = new Point(radius,0, #64b366);

Complex pt = new Complex(radius,0, #4dccb3);
Complex ptt = new Complex(radius,0, #f24447);
Complex ptf = new Complex(radius,0, #64b366);

void setup() {
    size(600, 600, P2D);
    gui = new LazyGui(this);
    smooth(8);
    surface.setLocation(450, 50);
    calculate();
}

void draw() {
    background(10,10,30);
    translate(width/2, height/2);
    scale(1,-1);
    drawAxes();
    // logic here
    calculate();

    drawPointLabel("V", ptf.x, ptf.y, ptf.col, false);
    drawPointLabel("V'", ptt.x, ptt.y, ptt.col, false);


    // Draw the circle based on the slider
    stroke(100,100,250);
    strokeWeight(3);
    noFill();
    circle(0, 0, radius * 2);

    // from point v
    // stroke(100,250,200);
    stroke(ptf.col);
    strokeWeight(2);
    dashedLine(0, 0, ptf.x, ptf.y, 8, 10);

    stroke(ptf.col);
    strokeWeight(12);
    point(ptf.x, ptf.y);

    // to point v'
    // stroke(200,250,100);
    stroke(ptt.col);
    strokeWeight(2);
    dashedLine(0, 0, ptt.x, ptt.y, 8, 10);

    stroke(ptt.col);
    strokeWeight(12);
    point(ptt.x, ptt.y);
    
    if (playing) {
        time += dt;
        if (time > 1.0) time = 1.0; 

        float theta_from = ptf.getPhase(); // Start Angle
        float theta_to   = ptt.getPhase(); // Target Angle

        float diff = theta_to - theta_from;

        // Fix the shortest path wrapping
        if (diff > PI)  diff -= TWO_PI;
        if (diff < -PI) diff += TWO_PI;

        float theta_current = theta_from + (diff * time);

        // Reset point to radius before rotating or it spirals out
        pt.x = radius; 
        pt.y = 0;

        pt.rotate(theta_current);

        // ONLY DRAW PT IF PLAYING
        stroke(pt.col);
        strokeWeight(2);
        dashedLine(0, 0, pt.x, pt.y, 8, 10);

        // stroke(100,250,100);
        stroke(pt.col);
        strokeWeight(12);
        point(pt.x, pt.y);
        drawPointLabel("v", pt.x, pt.y, pt.col, false);

        if (time >= 1.0) {
            println("Stopped");
            playing = false;
            time = 0;
        }
    }
    if (export) {
        // handle save frame logic here
    }

    handleGui();
}

void handleGui() {
    radius = gui.slider("radius", 100, 10, 200);
    thetaMain = gui.slider("thetaMain", 100, -1, 360);
    thetaFrom = gui.slider("thetaFrom", 100, -1, 360);
    thetaTo = gui.slider("thetaTo", 100, -1, 360);
    dt = gui.slider("dt", 0.005, 0.0001, 0.05);

    // pt.x = radius;
    // ptt.x = -radius;
    // ptf.y = radius;
    
    // if (thetaMain == 360) {
    //     thetaMain = 0;
    //     gui.sliderSet("thetaMain",0);
    // }

    if (thetaFrom== 360) {
        thetaFrom= 0;
        gui.sliderSet("thetaFrom",0);
    }

    if (thetaTo == 360) {
        thetaTo = 0;
        gui.sliderSet("thetaTo",0);
    }

    if (thetaFrom== -1) {
        thetaFrom= 359;
        gui.sliderSet("thetaFrom",359);
    }

    if (thetaTo == -1) {
        thetaTo = 359;
        gui.sliderSet("thetaTo",359);
    }

    if (gui.button("play")) {
        println("playing");
        playing = true;
        time = 0; // Reset time on play
    }


    if (gui.button("reset")) {
        radius = 100;
        gui.sliderSet("radius",100);

        thetaFrom = 0;
        gui.sliderSet("thetaFrom",0);

        thetaTo = 0;
        gui.sliderSet("thetaTo",0);
    }

    if (gui.button("quit")) {
        exit();
    }

    if (gui.hasChanged("radius")||
        gui.hasChanged("thetaMain")||
        gui.hasChanged("thetaFrom")||
        gui.hasChanged("thetaTo")
        ){
        // calculate();
    }
}

void calculate() {
    ptt.y = 0;
    ptt.x = radius;
    ptf.y = 0;
    ptf.x = radius;

    ptf.rotate(radians(thetaFrom));
    ptt.rotate(radians(thetaTo));
}

void drawAxes() {
    stroke(100);     
    strokeWeight(1); 
    fill(100);
    float axisLen = 275; 
    line(-axisLen, 0, axisLen, 0); 
    line(0, -axisLen, 0, axisLen); 
    float arrowSize = 6;
    pushMatrix();
    translate(axisLen, 0);
    triangle(0, 0, -arrowSize, -arrowSize/2, -arrowSize, arrowSize/2);
    popMatrix();
    pushMatrix();
    translate(-axisLen, 0);
    triangle(0, 0, arrowSize, -arrowSize/2, arrowSize, arrowSize/2);
    popMatrix();
    pushMatrix();
    translate(0, axisLen);
    triangle(0, 0, -arrowSize/2, -arrowSize, arrowSize/2, -arrowSize);
    popMatrix();
    pushMatrix();
    translate(0, -axisLen);
    triangle(0, 0, -arrowSize/2, arrowSize, arrowSize/2, arrowSize);
    popMatrix();
    pushMatrix();
    scale(1, -1); 
    textSize(14);
    fill(150);
    textAlign(CENTER, CENTER);
    text("+x", axisLen - 20, 20);      // Right
    text("-x", -axisLen + 20, 20);     // Left
    text("+y", 20, -axisLen + 20);     // Top (Note negative Y coord)
    text("-y", 20, axisLen - 20);      // Bottom (Note positive Y coord)
    popMatrix();
}

