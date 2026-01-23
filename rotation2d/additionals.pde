void drawDottedLine(float x1, float y1, float x2, float y2, float steps) {
  for (int i = 0; i <= steps; i++) {
    // lerp() calculates a point between 0.0 (start) and 1.0 (end)
    float x = lerp(x1, x2, i / steps);
    float y = lerp(y1, y2, i / steps);
    point(x, y); // Use point() for dots, or small rects/ellipses
  }
}

void dashedLine(float x1, float y1, float x2, float y2, float dashLen, float gapLen) {
  float totalDist = dist(x1, y1, x2, y2);
  float dx = (x2 - x1) / totalDist; // Unit vector X component
  float dy = (y2 - y1) / totalDist; // Unit vector Y component
  
  float currentDist = 0;
  
  while (currentDist < totalDist) {
    // 1. Calculate start of this dash
    float startX = x1 + dx * currentDist;
    float startY = y1 + dy * currentDist;
    
    // 2. Calculate end of this dash
    float endX = startX + dx * dashLen;
    float endY = startY + dy * dashLen;
    
    // 3. CLAMP: If this dash goes past the target, stop exactly at the target
    if (currentDist + dashLen > totalDist) {
      endX = x2;
      endY = y2;
    }
    
    line(startX, startY, endX, endY);
    
    // 4. Move forward by dash + gap
    currentDist += dashLen + gapLen;
  }
}

void drawPointLabel(String name, float x, float y, color c, boolean showCoords) {
    float offset = 45; // Distance from point
    float m = dist(0, 0, x, y);
    if (m == 0) m = 1;

    float tx = (x / m) * (m + offset);
    float ty = (y / m) * (m + offset);

    pushMatrix();
    translate(tx, ty);
    scale(1, -1); // Unflip text
    
    fill(c);
    textAlign(CENTER, CENTER);
    textSize(14);
    
    String label = name;
    if (showCoords) {
        label += "\n(" + nfc(x, 1) + ", " + nfc(y, 1) + ")";
    }
    
    text(label, 0, 0);
    
    popMatrix();
}	
