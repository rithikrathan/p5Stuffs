class complex{
	float re;
	float im;
	// not necessarily a part of the complexNumber
	// but these are used to construct the epicycles
	float Phase;
	float Frequency;
	float Amplitude;

	complex(float x, float y){ this.re = x; this.im = y;}

	void add(complex c){ this.re += c.re; this.im += c.im;}

	void multiply(complex c){
		float tempRe = this.re;
		this.re = (tempRe * c.re) - (this.im * c.im);
		this.im = (tempRe * c.im) + (c.re * this.im);
	}
}

//-=-=-=-=-=-=-=[Discrete Fourier Transform]=-=-=-==-=-=-=-=-
//
//     let:  R = (2πkn)/N, m = (N-1)/2 if odd else N/2;
//
//                   ₘ₋₁
//      Xₖ = (1/N) * ∑  (X₍ₙ₊ₘ₎* [cos(R) - i sin(R)] )
//                   ₙ₌₋ₘ
//
//      Where,
//          Xₖ        => The k-th Output Bin (Frequency Domain)
//          X₍ₙ₊ₘ₎    => The Input Signal Sample (Time Domain)
//          k         => Frequency Index (-m to m-1)
//          N         => Total number of samples


ArrayList<complex> dft(ArrayList<complex> Xn){
	ArrayList<complex> Xk = new ArrayList<complex>();

	int N = Xn.size(); //  total number of samples
	int m = (N % 2 == 0) ? N/2 : (N-1)/2;

	for (int k = -m; k < m - 1; k++) {
	// for (int k = 0; k < N; k++) {
		complex temp_k = new complex(0,0);
		for (int n = 0; n < N; n++) {
			float R = (2 * PI * n * k) / N ;
			complex temp_n = new complex(cos(R), -sin(R));
			temp_n.multiply(Xn.get(n));
			temp_k.add(temp_n);
		}

		temp_k.re = temp_k.re / N;
		temp_k.im= temp_k.im/ N;

		// construct epicycle 
		temp_k.Amplitude = sqrt(temp_k.re * temp_k.re + temp_k.im * temp_k.im); // radius
		temp_k.Phase = atan2(temp_k.im, temp_k.re); // angle
		temp_k.Frequency = k; // number of rotations per unit time

		Xk.add(temp_k);
	}
	if (resolution >= 0 && resolution < Xk.size()) {
		Xk.subList(resolution , Xk.size()).clear();
	}
	return Xk;
}

//-=-=-=-=-=-=-=[Inverse Discrete Fourier Transform]=-=-=-==-=-=-=-=-
//
//                         ₘ₋₁
//    z(t) = x(t) + y(t) ≈ ∑   Xₖ₊ₘ [cos(kt) + i sin(kt)], t ∈ [0,2π]
//                         ₖ₌₋ₘ
//
// calcualte the interpolation function and draw the closed curve
//  
//  NOTE: Whats the point of taking DFT and IDFT right after? isn't it useless?
//  > we pass in the points then get a function of "time" that approximately 
//		fills the missing path between points so we basically reverse
//		engineered a function using only by knowing its output.
//		This not a list of points like the input instead a single 
//		function that covers all of those points approximately.

// WARN: DO NOT PASS IN THE SORTED LIST OF "Xk"
PVector idft(float x ,float y, ArrayList<complex> Xk, float t, float scale){
	// where t is the time and is between [0,2π]
	complex zt = new complex(0,0);

	for (int k = 0; k < Xk.size(); k++) {
		float freq = Xk.get(k).Frequency;
		complex temp_k = new complex(cos(freq*  t),sin(freq* t));
		temp_k.multiply(Xk.get(k));
		zt.add(temp_k);
	}

	return new PVector(x + zt.re * scale, y + zt.im * scale);
}

//-=-=-=-=-=-=-=[Draw epicycles from Xk]=-=-=-==-=-=-=-=-

PVector drawEpicycles(float x, float y, float scale, float time, ArrayList<complex> Xk){
    float prevX = x;  
    float prevY = y;  

    if (resolution == -1) {
        resolution = Xk.size();
    }

    // Notice we just use the epicycle part of the complexNumber class nad not im or re 
    // Changed to standard loop to access index 'i' for gradient calculation
    for (int i = 0; i < Xk.size(); i++) {
        complex epicycle = Xk.get(i);
        float freq = epicycle.Frequency;

        if (freq > Xk.size() / 2) {
            freq -= Xk.size();
        }

        if (freq < resolution ) {

            // simple polar to cartesian conversion
            float currX = prevX + epicycle.Amplitude * scale * cos(freq * time + epicycle.Phase);
            float currY = prevY + epicycle.Amplitude * scale * sin(freq * time + epicycle.Phase);

            if (useEpicycleGradient) {
                 // Use the helper function defined in the main sketch
                 color c = getGradientColor(i, grad, epicycleColors);
                 stroke(c, 90);
            } else {
                 stroke(255, 90); 
            }
            
            strokeWeight(2); 
            noFill();
            circle(prevX, prevY, epicycle.Amplitude * 2 * scale);

            if (useEpicycleGradient) {
                 color c = getGradientColor(i, grad, epicycleColors);
                 stroke(c, 90);
            } else {
                 stroke(255, 90);
            }

            line(prevX,prevY, currX, currY);
            strokeWeight(4);
            point(currX, currY);
            prevX = currX;
            prevY = currY;
        }
    }

    stroke(0,255,0);
    strokeWeight(8);
    point(prevX,prevY);
    return new PVector(prevX, prevY); // returning a PVector so we can plot the shape
                                      // this is to avoid using the idft() to draw the path
                                      // as idft() also gives the same shape but takes time computing
}

void importJson(String path){
	JSONObject json = loadJSONObject(path);
	JSONArray points = json.getJSONArray("points");
	println("Loading shape: " + json.getString("name"));

	for (int i = 0; i < points.size(); i++) {
		JSONObject p = points.getJSONObject(i);
		float x = p.getFloat("x");
		float y = p.getFloat("y");
		Xn.add(new complex(x,y));
	}
}

class math2samples {
	float increment;

	math2samples(float increment) {
		this.increment = increment;
	}

	void circle(float cx, float cy, float radius){
		for (float t = 0; t < TAU; t += increment) {
			float x = cx + radius * cos(t);
			float y = cy + radius * sin(t);
			Xn.add(new complex(x,y));
		}
	}

	// freqX and freqY should be small integers (e.g., 3 and 2, or 5 and 4)
	void lissajous(float cx, float cy, float width, float height, float freqX, float freqY) {
		for (float t = 0; t < TAU; t += increment) {
			float x = cx + width * cos(freqX * t);
			float y = cy + height * sin(freqY * t);
			Xn.add(new complex(x, y));
		}
	}

	void epicycloid(float cx, float cy, float r, float R) {
		// Determine loop limit to ensure curve closes (simplification)
		// For simple integer ratios, TAU is usually enough or TAU*ratio
		float limit = TAU * 5; 

		for (float t = 0; t < limit; t += increment) {
			float x = cx + (R + r) * cos(t) - r * cos(((R + r) / r) * t);
			float y = cy + (R + r) * sin(t) - r * sin(((R + r) / r) * t);
			Xn.add(new complex(x, y));
		}
	}

	// R: radius of fixed circle
	// r: radius of rolling circle
	// d: distance of pen from center of rolling circle
	void hypotrochoid(float cx, float cy, float R, float r, float d) {
		// We may need to loop more than TAU to close the curve depending on the ratio of R/r
		float loops = 10 * TAU; 

		for (float t = 0; t < loops; t += increment) {
			float x = cx + (R - r) * cos(t) + d * cos(((R - r) / r) * t);
			float y = cy + (R - r) * sin(t) - d * sin(((R - r) / r) * t);
			Xn.add(new complex(x, y));
		}
	}

	// n: the number of petals (e.g., 6)
	// d: the "delta" angle step (try 71 or 29)
	void maurerRose(float cx, float cy, float radius, float n, float d) {
		// We loop through 360 degrees (in radians)
		for (float i = 0; i < 361; i++) {
			// The key is multiplying the angle 'k' by 'd' inside the sine function
			float k = i * d * (PI / 180); 
			float r = radius * sin(n * k);

			// Convert polar to cartesian
			// We use the 'k' angle for the coordinate mapping
			float x = cx + r * cos(k);
			float y = cy + r * sin(k);
			Xn.add(new complex(x, y));
		}
	}

	// a, b: radius width/height
	// n: exponent (0.5 = star, 1 = diamond, 2 = circle, 4+ = rounded square)
	void superellipse(float cx, float cy, float a, float b, float n) {
		for (float t = 0; t < TAU; t += increment) {
			float na = 2 / n;

			// We need 'sgn' (sign) function because pow() breaks with negative numbers
			// standard math trick: sgn(cos(t)) * abs(cos(t))^na

			float cosT = cos(t);
			float sinT = sin(t);

			float x = cx + a * (Math.signum(cosT) * pow(abs(cosT), na));
			float y = cy + b * (Math.signum(sinT) * pow(abs(sinT), na));

			Xn.add(new complex(x, y));
		}
	}

	void heartCurve(float cx, float cy, float scale) {
		for (float t = 0; t < TAU; t += increment) {
			// We use pow(sin(t), 3) for the X shape
			float xVal = 16 * pow(sin(t), 3);

			// This specific combination of Cosines creates the tapered point and dip
			float yVal = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);

			float x = cx + scale * xVal;
			// We subtract yVal because in many java graphics systems (like Swing/Processing),
			// Y goes DOWN. Subtracting flips it so the heart points up.
			float y = cy - scale * yVal; 

			Xn.add(new complex(x, -y));
		}
	}










}




