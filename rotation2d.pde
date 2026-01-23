import com.krab.lazy.LazyGui;

LazyGui gui;
float radius, prevRadius;

void setup() {
	size(800, 800, P2D);
	gui = new LazyGui(this);
	smooth(8);
}

void draw() {
	background(gui.colorPicker("background", color(50)).hex);
	handleGui();

	// Draw the circle based on the slider
	pushMatrix();
	translate(width/2, height/2);
	noStroke();
	fill(255);
	circle(0, 0, radius * 2);
	popMatrix();
}

void handleGui() {
	gui.pushFolder("controls");

	// 1. Create Slider
	radius = gui.slider("radius", 100, 10, 400);

	// 2. Check if slider changed -> Calculate
	if (radius != prevRadius) {
		calculate();
		prevRadius = radius;
	}

	// 3. Reset Button
	if (gui.button("reset")) {
		// Note: To reset the GUI slider visually, you typically need to set the internal value
		// gui.sliderSet("controls/radius", 100);
		println("Reset triggered");
	}

	// 4. Quit Button
	if (gui.button("quit")) {
		exit();
	}

	gui.popFolder();
}

void calculate() {
	// Only runs when the slider moves
	println("Calculating... Radius: " + radius);
	// Add complex calculation logic here
}
