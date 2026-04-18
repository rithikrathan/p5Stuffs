//objects
ArrayList<point> Points = new ArrayList<point>();
float[][] scaledPoints;

color innerColor = color(70, 10, 10);
color outerColor = color(100, 10, 10);
color[] curveColors;
int[] trailAlphas;
float[] trailWeights;

float digScale  = 2.8;
float resolution = 0.01;
int  shapeCount = 15;
float shapeSpace = 0.7;
boolean export = false;

float time = 0;
float speed = 69;
int trailLength = 200;

void setup() {
    frameRate(60);
    size(1200, 1200);
    background(100,100,190);
    scale(1,-1);
    heartCurve(0, 0, digScale);
    
    scaledPoints = new float[Points.size()][2];
    for (int i = 0; i < Points.size(); i++) {
        scaledPoints[i][0] = Points.get(i).x;
        scaledPoints[i][1] = Points.get(i).y;
    }
    
    curveColors = new color[shapeCount];
    for (int i = 0; i < shapeCount; i++) {
        float t = float(i) / (shapeCount - 1);
        curveColors[i] = lerpColor(innerColor, outerColor, t);
    }
    
    trailAlphas = new int[trailLength];
    trailWeights = new float[trailLength];
    for (int t = 0; t < trailLength; t++) {
        trailAlphas[t] = int(map(t, 0, trailLength, 255, 0));
        trailWeights[t] = map(t, 0, trailLength, 4, 1);
    }
}

void draw() {
    watermarkBackground(color(3,3,10), color(20), "@rathan_rithik");
    translate(600,600);
    scale(1,-1);

    drawAxes(580.0);

    for (int i = 0; i < shapeCount; i++) {
        float scaleFactor = (i + 1) * shapeSpace;
        
        stroke(80);
        strokeWeight(0.5);
        noFill();
        beginShape();
        for (int j = 0; j < scaledPoints.length; j++) {
            vertex(scaledPoints[j][0] * scaleFactor, scaledPoints[j][1] * scaleFactor);
        }
        endShape();
        
        stroke(curveColors[i]);
        strokeWeight(3);
        beginShape();
        for (int j = 0; j < scaledPoints.length; j++) {
            vertex(scaledPoints[j][0] * scaleFactor, scaledPoints[j][1] * scaleFactor);
        }
        endShape();

        for (int t = 0; t < trailLength; t++) {
            float trailTime = time / scaleFactor - t * 0.8;
            if (trailTime < 0) trailTime += scaledPoints.length;
            int idx = int(trailTime) % scaledPoints.length;
            
            int alpha = trailAlphas[t];
            stroke(255, 40, 40, alpha);
            strokeWeight(trailWeights[t]);
            
            point(scaledPoints[idx][0] * scaleFactor, scaledPoints[idx][1] * scaleFactor);
        }
    }

    time += speed;

    if (export) {
        saveFrame("videoFrames/frame-########.png");
    }
}
