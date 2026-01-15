public class complex{
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
		this.im = (tempRe * c.im) + (c.re + this.im);
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
// NOTE: make sure to explain the interpolation function
// Whats the point of taking DFT and IDFT right after? isn't it useless?
//  > we pass in the points then get a function of "time" that approximately 
//		fills the missing path between points so we basically reverse
//		engineered a function using only by knowing its output.

complex idft(ArrayList<complex> Xk, float t){
	// where t is the time and is between [0,2π]
	complex zt = new complex(0.0);

	for (int k = 0; k < Xk.size(); k++) {
		Xk.get(k).multiply(new complexNumber(cos(kt),sin(kt)));
	}
	return zt;
}

//-=-=-=-=-=-=-=[Draw epicycles from Xk]=-=-=-==-=-=-=-=-

PVector drawEpicycles(float x, float y, float scale, float time, ArrayList<complex> Xk){
    float prevX = x;  
    float prevY = y;  

    if (resolution == -1) {
        resolution = Xk.size();
    }

	// Notice we just use the epicycle part of the complexNumber class nad not im or re 
    for (complex epicycle : Xk) {
        float freq = epicycle.Frequency;

        if (freq > Xk.size() / 2) {
            freq -= Xk.size();
        }

        if (freq < resolution ) {

			// simple polar to cartesian conversion
            float currX = prevX + epicycle.Amplitude * scale * cos(freq * time + epicycle.Phase);
            float currY = prevY + epicycle.Amplitude * scale * sin(freq * time + epicycle.Phase);

            stroke(255, 90); 
            strokeWeight(2); 
            noFill();
            circle(prevX, prevY, epicycle.Amplitude * 2 * scale);
            stroke(255, 90);
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


