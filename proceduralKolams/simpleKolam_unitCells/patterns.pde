class pattern {
	int StrokeWeight;
	int Stroke_R;
	int Stroke_G;
	int Stroke_B;
	private float pscale = 3;

	pattern(int weight,int r,int g,int b){
		this.StrokeWeight = weight;
		this.Stroke_R = r;
		this.Stroke_G = g;
		this.Stroke_B = b;
	}


	void Point(point center, float matrixDensity){
		stroke(255,255,255);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void circle(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		ellipse(center.x, center.y, matrixDensity/0.7, matrixDensity/0.7);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void connectedUp(point center, float matrixDensity) {
		float radius = 100; // works only if radius < matrixDensity
		float phi = matrixDensity - radius;
		//calculate the shape using the radius
		line(center.x - radius, 0, center.x - radius,  center.y + phi);
		line(center.x, matrixDensity, center.x - radius,  center.y + phi);
		line(center.x + radius, 0, center.x + radius,  center.y + phi);
		line(center.x, matrixDensity, center.x + radius,  center.y + phi);
		arc(center.x, center.y, radius * 2 , radius * 2, radians(180), radians(360));

		strokeWeight(StrokeWeight* pscale);
		point(center.x, center.y);
	}

	void connectedDown(point center, float matrixDensity) {
		float radius = 100; // works only if radius < matrixDensity
		float phi = matrixDensity - radius;
		//calculate the shape using the radius
		line(center.x - radius, 0, center.x - radius,  center.y - phi);
		line(center.x, -matrixDensity, center.x - radius,  center.y - phi);
		line(center.x + radius, 0, center.x + radius,  center.y - phi);
		line(center.x, -matrixDensity, center.x + radius,  center.y - phi);
		arc(center.x, center.y, radius * 2 , radius * 2, radians(0), radians(180));

		strokeWeight(StrokeWeight* pscale);
		point(center.x, center.y);
	}

	void connectedLeft(point center, float matrixDensity) {
		float radius = 100; // works only if radius < matrixDensity
		float phi = matrixDensity - radius;
		//calculate the shape using the radius
		line(center.x, -radius, center.x -phi,  center.y - radius);
		line(-matrixDensity, 0, center.x - phi,  center.y - radius);
		line(center.x, radius, center.x -phi,  center.y + radius);
		line(-matrixDensity, 0, center.x - phi,  center.y + radius);
		arc(center.x, center.y, radius * 2 , radius * 2, radians(270), radians(450));

		strokeWeight(StrokeWeight* pscale);
		point(center.x, center.y);
	}

	void connectedRight(point center, float matrixDensity) {
		float radius = 100; // works only if radius < matrixDensity
		float phi = matrixDensity - radius;
		//calculate the shape using the radius
		line(center.x, radius, center.x +phi,  center.y + radius);
		line(matrixDensity, 0, center.x + phi,  center.y + radius);
		line(center.x, -radius, center.x +phi,  center.y - radius);
		line(matrixDensity, 0, center.x + phi,  center.y - radius);
		arc(center.x, center.y, radius * 2 , radius * 2, radians(90), radians(270));

		strokeWeight(StrokeWeight* pscale);
		point(center.x, center.y);
	}

	void catEars_bottomLeft(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		point arCenter = new point(matrixDensity/2,-matrixDensity/2);
		arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2), PI/4, 5*PI/4);
		line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void catEars_bottomRight(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		point arCenter = new point(-matrixDensity/2,-matrixDensity/2);
		arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),-HALF_PI+QUARTER_PI, PI-QUARTER_PI);
		line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void catEars_topLeft(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		point arCenter = new point(matrixDensity/2,matrixDensity/2);
		arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),PI-QUARTER_PI, TAU-QUARTER_PI);
		line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void catEars_topRight(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		point arCenter = new point(-matrixDensity/2,matrixDensity/2);
		arc(arCenter.x, arCenter.y, matrixDensity*sqrt(2), matrixDensity*sqrt(2),QUARTER_PI+PI,TAU+QUARTER_PI);
		line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void eyeHorizontal(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
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
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void eyeVertical(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
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
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void bottomPizzaSlice(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		line(center.x, center.y-matrixDensity, center.x + matrixDensity, center.y);
		line(center.x, center.y-matrixDensity, center.x - matrixDensity, center.y);
		arc(center.x, center.y, matrixDensity*2, matrixDensity*2, 0, PI);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void topPizzaSlice(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		line(center.x, center.y+matrixDensity, center.x + matrixDensity, center.y);
		line(center.x, center.y+matrixDensity, center.x - matrixDensity, center.y);
		arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI, TAU);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void leftPizzaSlice(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
		line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
		arc(center.x, center.y, matrixDensity*2, matrixDensity*2, PI/2, 3*PI/2);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}

	void rightPizzaSlice(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
		line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
		arc(center.x, center.y, matrixDensity*2, matrixDensity*2, -HALF_PI, PI/2);
		strokeWeight(StrokeWeight *pscale);
		point(center.x, center.y);
	}

	void diamond(point center, float matrixDensity) {
		stroke(Stroke_R,Stroke_G,Stroke_B);
		line(center.x-matrixDensity, center.y, center.x, center.y+ matrixDensity);
		line(center.x-matrixDensity, center.y, center.x, center.y- matrixDensity);
		line(center.x+matrixDensity, center.y, center.x, center.y+ matrixDensity);
		line(center.x+matrixDensity, center.y, center.x, center.y- matrixDensity);
		strokeWeight(StrokeWeight * pscale);
		point(center.x, center.y);
	}
}
