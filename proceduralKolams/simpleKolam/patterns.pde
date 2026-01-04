class pattern {
    int StrokeWeight;
    int Stroke_R;
    int Stroke_G;
    int Stroke_B;
    private float pscale = 3; 

    pattern(int weight, int r, int g, int b){
        this.StrokeWeight = weight;
        this.Stroke_R = r;
        this.Stroke_G = g;
        this.Stroke_B = b;
    }

    void setStyle(PGraphics pg, float matrixDensity) {
        pg.stroke(Stroke_R, Stroke_G, Stroke_B);
        
        float dynamicThickness = matrixDensity * (StrokeWeight / 40.0);
        pg.strokeWeight(max(1.0, dynamicThickness));
        pg.noFill();
    }

    void Point(PGraphics pg, point center, float matrixDensity){
        pg.stroke(Stroke_R, Stroke_G, Stroke_B);
        
        float dotSize = matrixDensity * (StrokeWeight / 40.0) * pscale;
        pg.strokeWeight(max(2.0, dotSize));
        pg.point(center.x, center.y);
    }

    void circle(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.ellipse(center.x, center.y, matrixDensity/0.7, matrixDensity/0.7);
        this.Point(pg, center, matrixDensity); 
    }

    void connectedUp(PGraphics pg, point center, float matrixDensity) {
        float radius = matrixDensity * 0.75; 
        float phi = matrixDensity - radius;
        setStyle(pg, matrixDensity);
        pg.line(center.x - radius, center.y, center.x - radius,  center.y + phi);
        pg.line(center.x, center.y + matrixDensity, center.x - radius,  center.y + phi);
        pg.line(center.x + radius, center.y, center.x + radius,  center.y + phi);
        pg.line(center.x, center.y + matrixDensity, center.x + radius,  center.y + phi);
        pg.arc(center.x, center.y, radius * 2 , radius * 2, radians(180), radians(360));
        this.Point(pg, center, matrixDensity); 
    }

    void connectedDown(PGraphics pg, point center, float matrixDensity) {
        float radius = matrixDensity * 0.75;
        float phi  = matrixDensity - radius;
        setStyle(pg, matrixDensity);
        pg.line(center.x - radius, center.y, center.x - radius,  center.y - phi);
        pg.line(center.x, center.y - matrixDensity, center.x - radius,  center.y - phi);
        pg.line(center.x + radius, center.y, center.x + radius,  center.y - phi);
        pg.line(center.x, center.y - matrixDensity, center.x + radius,  center.y - phi);
        pg.arc(center.x, center.y, radius * 2 , radius * 2, radians(0), radians(180));
        this.Point(pg, center, matrixDensity); 
    }

    void connectedLeft(PGraphics pg, point center, float matrixDensity) {
        float radius = matrixDensity * 0.75;
        float phi = matrixDensity - radius;
        setStyle(pg, matrixDensity);
        pg.line(center.x, center.y - radius, center.x - phi,  center.y - radius);
        pg.line(center.x - matrixDensity, center.y, center.x - phi,  center.y - radius);
        pg.line(center.x, center.y + radius, center.x - phi,  center.y + radius);
        pg.line(center.x - matrixDensity, center.y, center.x - phi,  center.y + radius);
        pg.arc(center.x, center.y, radius * 2 , radius * 2, radians(270), radians(450));
        this.Point(pg, center, matrixDensity); 
    }

    void connectedRight(PGraphics pg, point center, float matrixDensity) {
        float radius = matrixDensity * 0.75;
        float phi = matrixDensity - radius;
        setStyle(pg, matrixDensity);
        pg.line(center.x, center.y + radius, center.x + phi,  center.y + radius);
        pg.line(center.x + matrixDensity, center.y, center.x + phi,  center.y + radius);
        pg.line(center.x, center.y - radius, center.x + phi,  center.y - radius);
        pg.line(center.x + matrixDensity, center.y, center.x + phi,  center.y - radius);
        pg.arc(center.x, center.y, radius * 2 , radius * 2, radians(90), radians(270));
        this.Point(pg, center, matrixDensity); 
    }

    void catEars_bottomLeft(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x + matrixDensity, center.y,center.x,center.y + matrixDensity);
        pg.line(center.x + matrixDensity, center.y,center.x + matrixDensity /2,center.y - matrixDensity/2);
        pg.line(center.x - matrixDensity/2, center.y + matrixDensity/ 2,center.x,center.y + matrixDensity);
        pg.arc(center.x, center.y, matrixDensity*sqrt(2),matrixDensity*sqrt(2),radians(135),radians(315));
        this.Point(pg, center, matrixDensity);
    }

    void catEars_bottomRight(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x - matrixDensity, center.y,center.x,center.y + matrixDensity);
        pg.line(center.x - matrixDensity, center.y,center.x - matrixDensity /2,center.y - matrixDensity/2);
        pg.line(center.x + matrixDensity/2, center.y + matrixDensity/ 2,center.x,center.y + matrixDensity);
        pg.arc(center.x, center.y, matrixDensity*sqrt(2),matrixDensity*sqrt(2),radians(225),radians(405));
        this.Point(pg, center, matrixDensity);
    }

    void catEars_topLeft(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x + matrixDensity, center.y,center.x,center.y - matrixDensity);
        pg.line(center.x + matrixDensity, center.y,center.x + matrixDensity /2,center.y + matrixDensity/2);
        pg.line(center.x - matrixDensity/2, center.y - matrixDensity/ 2,center.x,center.y - matrixDensity);
        pg.arc(center.x, center.y, matrixDensity*sqrt(2),matrixDensity*sqrt(2),radians(45),radians(225));
        this.Point(pg, center, matrixDensity);
    }

    void catEars_topRight(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x - matrixDensity, center.y,center.x,center.y - matrixDensity);
        pg.line(center.x - matrixDensity, center.y,center.x - matrixDensity /2,center.y + matrixDensity/2);
        pg.line(center.x + matrixDensity/2, center.y - matrixDensity/ 2,center.x,center.y - matrixDensity);
        pg.arc(center.x, center.y, matrixDensity*sqrt(2),matrixDensity*sqrt(2),radians(315),radians(495));
        this.Point(pg, center, matrixDensity);
    }

    void eyeHorizontal(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.arc(center.x, center.y + matrixDensity, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(225), radians(315));
        pg.arc(center.x, center.y - matrixDensity, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(45), radians(135));
        this.Point(pg, center, matrixDensity);
    }

    void eyeVertical(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.arc(center.x - matrixDensity, center.y, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(315), radians(405));
        pg.arc(center.x + matrixDensity, center.y, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(135), radians(225));
        this.Point(pg, center, matrixDensity);
    }

    void bottomPizzaSlice(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x, center.y - matrixDensity, center.x + matrixDensity , center.y);
        pg.line(center.x, center.y - matrixDensity, center.x - matrixDensity , center.y);
        pg.arc(center.x, center.y - matrixDensity, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(45), radians(135));
        this.Point(pg, center, matrixDensity);
    }

    void topPizzaSlice(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x, center.y + matrixDensity, center.x + matrixDensity , center.y);
        pg.line(center.x, center.y + matrixDensity, center.x - matrixDensity , center.y);
        pg.arc(center.x, center.y + matrixDensity, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(225), radians(315));
        this.Point(pg, center, matrixDensity);
    }

    void leftPizzaSlice(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x - matrixDensity, center.y, center.x, center.y + matrixDensity);
        pg.line(center.x - matrixDensity, center.y, center.x, center.y - matrixDensity);
        pg.arc(center.x - matrixDensity, center.y, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(315), radians(405));
        this.Point(pg, center, matrixDensity);
    }

    void rightPizzaSlice(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x + matrixDensity, center.y, center.x, center.y + matrixDensity);
        pg.line(center.x + matrixDensity, center.y, center.x, center.y - matrixDensity);
        pg.arc(center.x + matrixDensity, center.y, matrixDensity*2*sqrt(2),matrixDensity*2*sqrt(2),radians(135), radians(225));
        this.Point(pg, center, matrixDensity);
    }

    void diamond(PGraphics pg, point center, float matrixDensity) {
        setStyle(pg, matrixDensity);
        pg.line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
        pg.line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
        pg.line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
        pg.line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
        this.Point(pg, center, matrixDensity);
    }
}
