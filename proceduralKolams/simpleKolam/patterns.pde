class patterns {
    void circle(point center, float matrixDensity) {
        ellipse(center.x, center.y, matrixDensity/1.4, matrixDensity/1.4);
    }

    void connectedUp(point center, float matrixDensity) {
        line(center.x, center.y+matrixDensity, center.x + matrixDensity/2, center.y);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity/2, center.y);
        arc(center.x, center.y, matrixDensity, matrixDensity, PI, TAU);
    }

    void connectedDown(point center, float matrixDensity) {
        line(center.x, center.y-matrixDensity, center.x + matrixDensity/2, center.y);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity/2, center.y);
        arc(center.x, center.y, matrixDensity, matrixDensity, 0, PI);
    }

    void connectedLeft(point center, float matrixDensity) {
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity/2);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity/2);
        arc(center.x, center.y, matrixDensity, matrixDensity, PI/2, 3*PI/2);
    }

    void connectedRight(point center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity/2);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity/2);
        arc(center.x, center.y, matrixDensity, matrixDensity, -HALF_PI, PI/2);
    }

    void catEars_bottomLeft(point center, float matrixDensity) {
		point arCenter = new point(matrixDensity/2,-matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2), PI/4, 5*PI/4);
        line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
    }
	
    void catEars_bottomRight(point center, float matrixDensity) {
		point arCenter = new point(-matrixDensity/2,-matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),-HALF_PI+QUARTER_PI, PI-QUARTER_PI);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
    }

    void catEars_topLeft(point center, float matrixDensity) {
		point arCenter = new point(matrixDensity/2,matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),PI-QUARTER_PI, TAU-QUARTER_PI);
        line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
    }

    void catEars_topRight(point center, float matrixDensity) {
		point arCenter = new point(-matrixDensity/2,matrixDensity/2);
        arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),QUARTER_PI+PI,TAU+QUARTER_PI);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
    }

    void eyeHorizontal(point center, float matrixDensity) {
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
    }

    void eyeVertical(point center, float matrixDensity) {
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
    }

    void bottomPizzaSlice(point center, float matrixDensity) {
        line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
        line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, 0, PI);
    }

    void topPizzaSlice(point center, float matrixDensity) {
        line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
        line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI, TAU);
    }

    void leftPizzaSlice(point center, float matrixDensity) {
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI/2, 3*PI/2);
    }

    void rightPizzaSlice(point center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
        arc(center.x, center.y, matrixDensity*2, matrixDensity*2, -HALF_PI, PI/2);
    }

    void diamond(point center, float matrixDensity) {
        line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
        line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
    }
}
