class point {
    float x, y;

    point(float x, float y) {
        this.x = x;
        this.y = y;
    }
}

void heartCurve(float cx, float cy, float scale) {
    for (float t = 0; t < TAU; t += resolution) {
        float xVal = 16 * pow(sin(t), 3);
        float yVal = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t);
        float x = cx + scale * xVal;
        float y = cy - scale * yVal; 
        Points.add(new point(x, -y));
    }
}
