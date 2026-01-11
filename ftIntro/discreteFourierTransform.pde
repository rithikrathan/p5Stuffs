ArrayList<complex> dft(ArrayList<complex> Xn){
	int N = Xn.size();
	ArrayList<complex> Xk = new ArrayList<complex>();

	// int m; //  *i believe* this "m" is the range of frequencies
	
	// if (N % 2 == 0) {
	// 	m = N/2;
	// } else{
	// 	m = (N - 1) / 2;
	// }
	
	// // X_k = (1/N) * SUM[n = -m to m-1] of ( x_(n+m) * [ cos(2 * pi * k * n / N) - i * sin(2 * pi * k * n / N) ] )

	for (int k= 0 ; k < N ; k++) {
		complex temp_k = new complex(0 , 0);
		for (int n = 0 ; n < N ; n++) {
			// R = 2PIkn/N all constants grouped
			// Xn[n] . cos(R) - isin(R) // 
			float R = (2 * PI * n *k) / N;
			complex temp_n = new complex(cos(R), -sin(R));	
			temp_n.multiply(Xn.get(n));
			temp_k.add(temp_n);
		}

		temp_k.re = temp_k.re / N;
		temp_k.im = temp_k.im / N;
		temp_k.Amplitude = sqrt(temp_k.re *  temp_k.re + temp_k.im * temp_k.im);
		temp_k.Phase = atan2(temp_k.im,temp_k.re);
		temp_k.Frequency = k;

		Xk.add(temp_k);
	}
	return Xk;
}
