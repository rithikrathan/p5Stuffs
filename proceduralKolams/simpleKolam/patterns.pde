class patterns {
	void Point(unitCell center, float matrixDensity){
		stroke(255,255,255);
		strokeWeight(4);
		point(center.x, center.y);
	}

    void circle(unitCell center, float matrixDensity) {
        ellipse(center.x, center.y, matrixDensity/1.4, matrixDensity/1.4);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void connectedUp(unitCell center, float matrixDensity) {
        line(center.x, center.y+matrixDensity, center.x + matrixDensity/2, center.y);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity/2, center.y);
        arc(center.x, center.y, matrixDensity, matrixDensity, PI, TAU);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void connectedDown(unitCell center, float matrixDensity) {
        line(center.x, center.y-matrixDensity, center.x + matrixDensity/2, center.y);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity/2, center.y);
        arc(center.x, center.y, matrixDensity, matrixDensity, 0, PI);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void connectedLeft(unitCell center, float matrixDensity) {
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity/2);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity/2);
        arc(center.x, center.y, matrixDensity, matrixDensity, PI/2, 3*PI/2);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void connectedRight(unitCell center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity/2);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity/2);
        arc(center.x, center.y, matrixDensity, matrixDensity, -HALF_PI, PI/2);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void catEars_bottomLeft(unitCell center, float matrixDensity) {
		point arCenter = new point(matrixDensity/2,-matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2), PI/4, 5*PI/4);
        line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
		strokeWeight(12);
		point(center.x, center.y);
    }
	
    void catEars_bottomRight(unitCell center, float matrixDensity) {
		point arCenter = new point(-matrixDensity/2,-matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),-HALF_PI+QUARTER_PI, PI-QUARTER_PI);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void catEars_topLeft(unitCell center, float matrixDensity) {
		point arCenter = new point(matrixDensity/2,matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),PI-QUARTER_PI, TAU-QUARTER_PI);
        line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void catEars_topRight(unitCell center, float matrixDensity) {
		point arCenter = new point(-matrixDensity/2,matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),QUARTER_PI+PI,TAU+QUARTER_PI);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void eyeHorizontal(unitCell center, float matrixDensity) {
		float tipDist = 2 * matrixDensity;
		float R = sqrt(2) * matrixDensity;   
		float d = tipDist / 2;

		float theta = acos(d / R);

		arc(center.x - d, center.y,
			R*2, R*2,
			-theta, theta);

		arc(center.x + d, center.y,
			R*2, R*2,
			PI - theta, PI + theta);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void eyeVertical(unitCell center, float matrixDensity) {
		float tipDist = 2 * matrixDensity;
		float R = sqrt(2) * matrixDensity;
		float d = tipDist / 2;

		float theta = acos(d / R);

		arc(center.x, center.y - d,
			R*2, R*2,
			HALF_PI - theta, HALF_PI + theta);

		arc(center.x, center.y + d,
			R*2, R*2,
			-HALF_PI - theta, -HALF_PI + theta);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void bottomPizzaSlice(unitCell center, float matrixDensity) {
        line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, 0, PI);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void topPizzaSlice(unitCell center, float matrixDensity) {
        line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI, TAU);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void leftPizzaSlice(unitCell center, float matrixDensity) {
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI/2, 3*PI/2);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void rightPizzaSlice(unitCell center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, -HALF_PI, PI/2);
		strokeWeight(12);
		point(center.x, center.y);
    }

    void diamond(unitCell center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
		strokeWeight(12);
		point(center.x, center.y);
    }
}
