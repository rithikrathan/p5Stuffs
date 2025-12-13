
class shapes {
    void circle(vertex point, float matrixDensity) {
        ellipse(point.x, point.y, matrixDensity/1.4, matrixDensity/1.4);
    }
	//-=-=-=-=-=-= not a raindrop thing

    void connectedUp(vertex point, float matrixDensity) {
        line(point.x, point.y+matrixDensity, point.x + matrixDensity, point.y);
        line(point.x, point.y+matrixDensity, point.x - matrixDensity, point.y);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, PI, TAU);
        // point(point.x, point.y + 10);
    }

    void connectedDown(vertex point, float matrixDensity) {
        line(point.x, point.y-matrixDensity, point.x + matrixDensity, point.y);
        line(point.x, point.y-matrixDensity, point.x - matrixDensity, point.y);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, 0, PI);
    }

    void connectedLeft(vertex point, float matrixDensity) {
        line(point.x+matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x+matrixDensity, point.y, point.x, point.y- matrixDensity);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, PI/2, 3*PI/2);
    }

    void connectedRight(vertex point, float matrixDensity) {
        line(point.x-matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x-matrixDensity, point.y, point.x, point.y- matrixDensity);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, -HALF_PI, PI/2);
    }
	//-=-=-=-=-=-=-=-=-= md*2  -> md/sqrt(2)

    void catEars_bottomLeft(vertex point, float matrixDensity) {
		vertex center = new vertex(matrixDensity/2,-matrixDensity/2);
        arc(center.x, center.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2), PI/4, 5*PI/4);
        line(point.x, point.y-matrixDensity, point.x + matrixDensity, point.y);
    }
	
    void catEars_bottomRight(vertex point, float matrixDensity) {
		vertex center = new vertex(-matrixDensity/2,-matrixDensity/2);
        arc(center.x, center.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),-HALF_PI+QUARTER_PI, PI-QUARTER_PI);
        line(point.x, point.y-matrixDensity, point.x - matrixDensity, point.y);
    }

    void catEars_topLeft(vertex point, float matrixDensity) {
		vertex center = new vertex(matrixDensity/2,matrixDensity/2);
        arc(center.x, center.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),PI-QUARTER_PI, TAU-QUARTER_PI);
        line(point.x, point.y+matrixDensity, point.x + matrixDensity, point.y);
    }

    void catEars_topRight(vertex point, float matrixDensity) {
		vertex center = new vertex(-matrixDensity/2,matrixDensity/2);
        arc(center.x, center.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),QUARTER_PI+PI,TAU+QUARTER_PI);
        line(point.x, point.y+matrixDensity, point.x - matrixDensity, point.y);
    }

    void eyeHorizontal(vertex point, float matrixDensity) {
        arc(point.x, point.y, matrixDensity*2, matrixDensity, 0, PI);
        arc(point.x, point.y, matrixDensity*2, matrixDensity, PI, TAU);
    }

    void eyeVertical(vertex point, float matrixDensity) {
        arc(point.x, point.y, matrixDensity*2, matrixDensity, PI/2, 3*PI/2);
        arc(point.x, point.y, matrixDensity*2, matrixDensity, -HALF_PI, PI/2);
    }

    void bottomPizzaSlice(vertex point, float matrixDensity) {
        line(point.x, point.y-matrixDensity, point.x + matrixDensity, point.y);
        line(point.x, point.y-matrixDensity, point.x - matrixDensity, point.y);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, 0, PI);
    }

    void topPizzaSlice(vertex point, float matrixDensity) {
        line(point.x, point.y+matrixDensity, point.x + matrixDensity, point.y);
        line(point.x, point.y+matrixDensity, point.x - matrixDensity, point.y);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, PI, TAU);
        // point(point.x, point.y + 10);
    }

    void leftPizzaSlice(vertex point, float matrixDensity) {
        line(point.x+matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x+matrixDensity, point.y, point.x, point.y- matrixDensity);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, PI/2, 3*PI/2);
    }

    void rightPizzaSlice(vertex point, float matrixDensity) {
        line(point.x-matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x-matrixDensity, point.y, point.x, point.y- matrixDensity);
        arc(point.x, point.y, matrixDensity*2, matrixDensity*2, -HALF_PI, PI/2);
    }

    void diamond(vertex point, float matrixDensity) {
        line(point.x-matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x-matrixDensity, point.y, point.x, point.y- matrixDensity);
        line(point.x+matrixDensity, point.y, point.x, point.y+ matrixDensity);
        line(point.x+matrixDensity, point.y, point.x, point.y- matrixDensity);
    }
}
