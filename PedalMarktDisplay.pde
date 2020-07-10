PVector origin;
PVector size;

float lerpX(float amount) {
  return lerp(origin.x, origin.x + size.x, amount);
}

float lerpY(float amount) {
  return lerp(origin.y, origin.y + size.y, amount);
}

float lerpW(float amount) {
  return lerp(0, size.x, amount);
}

float lerpH(float amount) {
  return lerp(0, size.y, amount);
}

void setup() {
  origin = new PVector(0, 0);
  // size = new PVector(320, 240);
  // size(size.x, size.y);
  fullScreen();
  size = new PVector(width, height);
  // noCursor();
  colorMode(HSB, 100);
  frameRate(24);
}

interface Step {
  void run(float playhead, int iteration);
}

void draw() {
  clear();
  Step[] steps = {
    new ColorStep(),
    new TestStep(),
  };
  int m = millis();
  int duration = 5 * 1000;
  int iteration = floor(m / duration);
  int stepInd = iteration % steps.length;
  float playhead = float(m - iteration * duration) / duration;
  steps[stepInd].run(playhead, iteration);
}

class TestStep implements Step {
  void run(float playhead, int iteration) {
    background(0, 0, 10);
    fill(0, 0, 100);
    rect(lerpX(0.1), lerpY(0.2), lerpW(0.2), lerpH(0.5));
  }
}


class ColorStep implements Step {
  void run(float playhead, int iteration) {
    color c1 = color(40, 40, 100);
    color c2 = color(100, 20, 60);
    println(playhead);
    background(lerpColor(c1, c2, playhead));
  }
}
