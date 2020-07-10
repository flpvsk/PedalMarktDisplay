PVector vOrigin;
PVector vSize;

Step[] steps;

float lerpX(float amount) {
  return lerp(vOrigin.x, vOrigin.x + vSize.x, amount);
}

float lerpY(float amount) {
  return lerp(vOrigin.y, vOrigin.y + vSize.y, amount);
}

float lerpW(float amount) {
  return lerp(0, vSize.x, amount);
}

float lerpH(float amount) {
  return lerp(0, vSize.y, amount);
}

void settings() {
  // size(320, 240);
  fullScreen();
  // noCursor();
}

color C_GREY;
color C_PURPLE;
color C_GREEN;

void setup() {
  vOrigin = new PVector(0, 0);
  vSize = new PVector(width, height);

  colorMode(HSB, 100);
  frameRate(24);

  steps = new Step[] {
    new MainLogoStep(),
    new ColorStep(),
    // new TestStep(),
  };

  for (Step step : steps) {
    step.setup();
  }

  C_GREY = color(0, 0, 10);
  C_PURPLE = color(34600 / 360, 43, 52);
  C_GREEN = color(17900 / 360, 100, 71);
}

interface Step {
  void run(float playhead, int iteration);
  void setup();
}

void draw() {
  clear();
  int m = millis();
  int duration = 2 * 1000;
  int iteration = floor(m / duration);
  int stepInd = iteration % steps.length;
  float playhead = float(m - iteration * duration) / duration;
  steps[stepInd].run(playhead, iteration);
}

class TestStep implements Step {
  void setup() {}
  void run(float playhead, int iteration) {
    background(C_GREY);
    fill(0, 0, 100);
    rect(lerpX(0.1), lerpY(0.2), lerpW(0.2), lerpH(0.5));
  }
}


class ColorStep implements Step {
  void setup() {}
  void run(float playhead, int iteration) {
    color c1 = C_GREY;
    color c2 = C_GREY;
    if (playhead < 1.0) {
      c1 = C_GREEN;
      c2 = C_GREY;
    }
    if (playhead < 0.6) {
      c1 = C_PURPLE;
      c2 = C_GREEN;
    }
    if (playhead < 0.3) {
      c1 = C_GREY;
      c2 = C_PURPLE;
    }
    background(lerpColor(c1, c2, playhead));
  }
}

class MainLogoStep implements Step {
  PImage pmMain;

  void setup() {
    this.pmMain = loadImage("media/pedal-markt-main.png");
  }

  void run(float playhead, int iteration) {
    background(C_GREY);
    image(
      this.pmMain,
      (width - this.pmMain.width) / 2, (height - this.pmMain.height) / 2,
      this.pmMain.width, this.pmMain.height
    );
  }
}
