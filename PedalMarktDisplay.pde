// import processing.video.*;
import gohai.glvideo.*;

// import com.hamoid.VideoExport;
// VideoExport videoExport;

PVector vOrigin;
PVector vSize;
int currentIterationStart = 0;
int currentIterationDuration = 0;
int currentIteration = 0;

Step[] steps;

float lerpX(float amount) {
  return lerp(vOrigin.x, vOrigin.x + vSize.x, amount);
}

float lerpY(float amount) {
  return lerp(vOrigin.y, vOrigin.y + vSize.y, amount);
}

float lerpYMargin(float amount, float margin) {
  float marginY = lerpH(margin);
  return lerp(vOrigin.y + marginY, vOrigin.y + vSize.y - marginY, amount);
}

float lerpW(float amount) {
  return lerp(0, vSize.x, amount);
}

float lerpH(float amount) {
  return lerp(0, vSize.y, amount);
}

color genBrightColor(float seed) {
  return color(noise(seed) * 100, 100, 100);
}

color genDarkColor(float seed) {
  return color(noise(seed) * 100, 70, 50);
}

void settings() {
  // size(640, 480, P2D);
  fullScreen(P2D);
}

// void movieEvent(Movie movie) {
//   movie.read();
// }

color C_GREY;
color C_PURPLE;
color C_GREEN;
color C_WHITE;

void setup() {
  noCursor();

  // videoExport = new VideoExport(this);
  // videoExport.startMovie();

  vOrigin = new PVector(0, 0);
  vSize = new PVector(width, height);

  colorMode(HSB, 100);
  frameRate(24);

  steps = new Step[] {
    new ShowVideoStep(),
    new Oscilations4(),
    new FigureStep(),
    new MainLogoStep(),
    new Oscilations3(),
    new TextStep(),
    new TextStep(),
    new ShowVideoStep(),
    new DottedLinesStep(),
    new Oscilations2(),
    new MainLogoStep(),
    new Oscilations1(),
    new TextStep(),
  };

  for (Step step : steps) {
    step.setup(this);
  }

  C_GREY = color(0, 0, 10);
  C_PURPLE = color(34600 / 360, 43, 52);
  C_GREEN = color(17900 / 360, 100, 71);
  C_WHITE = color(0, 0, 100);
}

interface Step {
  void run(float playhead, int iteration);
  void setup(PApplet parent);
}

void draw() {
  int m = millis();

  if (currentIterationStart + currentIterationDuration < m) {
    currentIterationStart = m;
    currentIterationDuration = floor(random(2000, 8000));
    currentIteration += 1;
    clear();
  }

  int currentProgress = m - currentIterationStart;
  int stepInd = currentIteration % steps.length;
  float playhead = float(currentProgress) / currentIterationDuration;
  steps[stepInd].run(playhead, currentIteration);

  // videoExport.saveFrame();
}

void keyPressed() {
  // if (key == 'q') {
  //   videoExport.endMovie();
  //   exit();
  // }
}

class TestStep implements Step {
  void setup(PApplet parent) {}
  void run(float playhead, int iteration) {
    clear();
    fill(0, 0, 100);
    noStroke();
    rect(lerpX(0.1), lerpY(0.2), lerpW(0.2), lerpH(0.5));
  }
}


class ColorStep implements Step {
  void setup(PApplet parent) {}
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

  void setup(PApplet parent) {
    this.pmMain = loadImage("media/pedal-markt-main.png");
  }

  void run(float playhead, int iteration) {
    clear();
    tint(genBrightColor(100.0 * iteration));
    image(
      this.pmMain,
      (width - this.pmMain.width) / 2,
      (height - this.pmMain.height) / 2,
      this.pmMain.width, this.pmMain.height
    );
    noTint();
  }
}

class DottedLinesStep implements Step {
  void setup(PApplet parent) {
  }

  void run(float playhead, int iteration) {
    clear();
    int lines = floor(noise(0, iteration) * 10) + 1;
    float y = 0;

    for (int i = 0; i < lines; i++) {
      y += noise(i + 1, iteration) * 0.3;
      this.drawDottedLine(
        y,
        noise(i + 2, iteration) * 0.05,
        noise(i + 3, iteration) * 0.1,
        noise(i + 4, iteration) * 0.1,
        noise(i + 5, iteration) * 100,
        playhead,
        genBrightColor(noise(i, iteration))
      );
    }
  }

  void drawDottedLine(
    float y,
    float h,
    float wDot,
    float wSpace,
    float slowdown,
    float playhead,
    color c
  ) {
    float pl = round(playhead * slowdown) / slowdown;
    float wPart = wDot + wSpace;
    int n = floor(1 / wPart);
    for (int i = 0; i <= n; i++) {
      float x = (i * wPart + pl);
      x = x % 1;

      float w = wDot;
      fill(c);
      noStroke();
      rect(lerpX(x), lerpY(y), lerpW(w), lerpH(h));
    }
  }
}

class Oscilations1 implements Step {
  float seed;

  void setup(PApplet parent) {
    this.seed = random(1);
  }

  void run(float playhead, int iteration) {
    clear();

    // drawGrid(4, 4, genDarkColor(this.seed * iteration * 100));

    float freq = noise(seed) * 10;
    int reduceQ = 5;
    float pointCount = int(width / reduceQ);
    float phi = playhead * 100 * TWO_PI * noise(seed * iteration);
    // float phi = 0.0;

    noFill();
    strokeWeight(4);
    stroke(genBrightColor(this.seed * iteration));

    beginShape();
    for (int i = 0; i <= pointCount; i++) {
      float angle = map(i, 0, pointCount, 0, TWO_PI);
      float y = lerpYMargin(
        (sin(angle * freq + radians(phi)) + 1) / 2,
        0.2
      );
      vertex(i * reduceQ, y);
    }
    endShape();
  }
}

class Oscilations2 implements Step {
  float seed;

  void setup(PApplet parent) {
    this.seed = random(1);
  }

  void run(float playhead, int iteration) {
    clear();

    drawGrid(10, 10, genDarkColor(this.seed * iteration * 100));

    // float freqCarrier = 1;
    float freqCarrier = (
      noise(iteration * 1, seed) *
      pow(10, floor(noise(iteration * 2, seed) * 3))
    );
    // float freqSignal = 0.2;
    float freqSignal = (
      noise(iteration * 3, seed) *
      pow(10, floor(noise(iteration * 4, seed) * 3))
    );

    int reduceQ = 5;
    float pointCount = int(width / reduceQ);
    float phi = playhead * 100 * TWO_PI * noise(seed * iteration);

    noFill();
    stroke(genBrightColor(this.seed * iteration));
    strokeWeight(4);

    beginShape();
    for (int i = 0; i <= pointCount; i++) {
      float angle = map(i, 0, pointCount, 0, TWO_PI);
      float signal = sin(angle * freqSignal + radians(phi));
      float carrier = cos(angle * freqCarrier);
      float y = lerpYMargin((signal * carrier + 1) / 2, 0.2);
      vertex(i * 5, y);
    }
    endShape();
  }
}

class Oscilations3 implements Step {
  float seed;

  void setup(PApplet parent) {
    this.seed = random(1);
  }

  void run(float playhead, int iteration) {
    clear();

    // float freqCarrier = 1;

    float freqCarrierX = (
      noise(iteration * 1, seed) *
      pow(10, floor(noise(iteration * 2, seed) * 3))
    );

    float freqCarrierY = (
      noise(iteration * 3, seed) *
      pow(10, floor(noise(iteration * 4, seed) * 3))
    );

    // float freqSignal = 0.2;
    float freqSignalX = (
      noise(iteration * 5, seed) *
      pow(10, floor(noise(iteration * 6, seed) * 3))
    );

    float freqSignalY = (
      noise(iteration * 7, seed) *
      pow(10, floor(noise(iteration * 8, seed) * 3))
    );

    int reduceQ = 3;
    float pointCount = int(width / reduceQ);
    float phi = round(playhead * 5 * TWO_PI * 4.0) / 4.0;

    noFill();
    strokeWeight(4);
    stroke(genBrightColor(this.seed * iteration));

    int start = 0;
    int finish = 0;

    if (playhead < 0.5) {
      float eased = map2(playhead, 0, 0.5, 0, 1, CUBIC, EASE_IN);
      start = 0;
      finish = int(pointCount * eased);
    }

    if (playhead >= 0.5) {
      float eased = map2(playhead, 0.5, 1, 0, 1, CUBIC, EASE_OUT);
      start = int(eased * pointCount);
      finish = int(pointCount);
    }

    beginShape();
    for (int i = start; i <= finish; i++) {
      float angle = map(i, 0, pointCount, 0, TWO_PI);

      float x = (
        sin(angle * freqSignalX + radians(phi)) *
        cos(angle * freqCarrierX) +
        1
      ) / 2;

      float y = (
        sin(angle * freqSignalY) *
        cos(angle * freqCarrierY) +
        1
      ) / 2;

      vertex(lerpX(x), lerpYMargin(y, 0.1));
    }

    endShape();
  }
}

interface Op {
  float apply(float a1, float a2);
}

class Mult implements Op {
  float apply(float a1, float a2) {
    return a1 * a2;
  }
}

class Sum implements Op {
  float apply(float a1, float a2) {
    return (a1 + a2) / 2;
  }
}

class Pow implements Op {
  float apply(float a1, float a2) {
    return pow(a1, a2);
  }
}

class Div implements Op {
  float apply(float a1, float a2) {
    return a1 / (a2 + 1);
  }
}

void drawGrid(int rows, int cols, color c) {
  int midC = round(cols / 2);
  int midR = round(rows / 2);
  for (int row = 1; row <= rows - 1; row++) {
    strokeWeight(1 + int(row == midR) * 3);
    stroke(c);
    line(
      lerpX(0),
      lerpY(float(row) / rows),
      lerpX(1),
      lerpY(float(row) / rows)
    );
  }

  for (int col = 1; col <= cols - 1; col++) {
    strokeWeight(1 + int(col == midC) * 3);
    stroke(c);
    line(
      lerpX(float(col) / cols),
      lerpY(0),
      lerpX(float(col) / cols),
      lerpY(1)
    );
  }
}

class Oscilations4 implements Step {
  float seed;
  Op ops[];

  void setup(PApplet parent) {
    this.seed = random(1);
    this.ops = new Op[] {
      // new Mult(),
      // new Sum(),
      new Div(),
    };
  }

  void run(float playhead, int iteration) {
    clear();
    drawGrid(10, 10, genDarkColor(this.seed * iteration * 100));
    // float freqCarrier = 1;
    float freqCarrier = (
      noise(iteration * 1, seed) *
      pow(10, floor(noise(iteration * 2, seed) * 3))
    );
    // float freqSignal = 0.2;
    float freqSignal = (
      noise(iteration * 3, seed) *
      pow(10, floor(noise(iteration * 4, seed) * 3))
    );

    int reduceQ = 5;
    int pointCount = int(width / reduceQ);
    float phi = playhead * 100 * TWO_PI * noise(seed * iteration);
    Op op = ops[floor(noise(iteration, seed) * 10) % ops.length];

    noFill();
    stroke(genBrightColor(this.seed * iteration));
    strokeWeight(4);

    float[] signalPoints = new float[pointCount];
    float[] carrierPoints = new float[pointCount];

    for (int i = 0; i < pointCount; i++) {
      float angle = map(i, 0, pointCount, 0, TWO_PI);
      float signal = (1 + sin(angle * freqSignal + radians(phi))) / 2;
      float carrier = (1 + sin(angle * freqCarrier + radians(phi))) / 2;
      signalPoints[i] = signal;
      carrierPoints[i] = carrier;
    }

    beginShape();
    for (int i = 0; i < pointCount; i++) {
      float y = lerp(
        vOrigin.y + vSize.y * 0.05,
        vOrigin.y + vSize.y * 0.3,
        signalPoints[i]
      );
      vertex(i * 5, y);
    }
    endShape();

    beginShape();
    for (int i = 0; i < pointCount; i++) {
      float y = lerp(
        vOrigin.y + vSize.y * 0.36,
        vOrigin.y + vSize.y * 0.63,
        carrierPoints[i]
      );
      vertex(i * 5, y);
    }
    endShape();

    beginShape();
    for (int i = 0; i < pointCount; i++) {
      float y = lerp(
        vOrigin.y + vSize.y * 0.69,
        vOrigin.y + vSize.y * 0.95,
        op.apply(signalPoints[i],  carrierPoints[i])
      );

      vertex(i * 5, y);
    }
    endShape();
  }
}

class FigureStep implements Step {
  float seed;
  String[] letters = {
    "л",
    "ю",
    "б",
    "о",
    "в",
    "ь"
  };

  void setup(PApplet parent) {
    this.seed = random(1);
  }

  void run(float playhead, int iteration) {
    clear();
    int figures = int(noise(iteration * seed) * 5) + 1;
    blendMode(EXCLUSION);
    for (int i = 0; i < figures; i++) {
      int f = int(noise(iteration * seed * i) * 10) % 4;

      if (f == 0) {
        drawLine(iteration >> i);
        continue;
      }

      if (f == 1) {
        drawRect(iteration >> i);
        continue;
      }

      if (f == 2) {
        drawCircle(iteration >> i);
        continue;
      }

      drawLetter(iteration >> i);
    }
    blendMode(BLEND);
  }

  void drawLine(int iteration) {
    strokeWeight(noise(seed * iteration * 195) * 20);
    stroke(genBrightColor(noise(seed * iteration, 10)));
    noFill();

    line(
      lerpX(noise(seed * iteration * 10)),
      lerpY(noise(seed * iteration * 11)),
      lerpX(noise(seed * iteration * 12)),
      lerpY(noise(seed * iteration * 13))
    );

    noStroke();
  }

  void drawLetter(int iteration) {
    noStroke();
    fill(
      genBrightColor(noise(seed * iteration, 11))
    );

    int ind = floor(noise(iteration * seed * 101) * this.letters.length);

    textSize(50 + 200 * noise(iteration * seed, 102));

    text(
      this.letters[ind],
      lerpX(noise(seed * iteration * 102)),
      lerpY(noise(seed * iteration * 103))
    );

    noFill();
  }

  void drawCircle(int iteration) {
    noStroke();
    fill(
      genBrightColor(noise(seed * iteration, 12))
    );

    float r = lerpH(noise(seed * iteration * 113));
    ellipse(
      lerpX(noise(seed * iteration * 111)),
      lerpY(noise(seed * iteration * 112)),
      r,
      r
    );
    noFill();
  }

  void drawRect(int iteration) {
    fill(
      genBrightColor(noise(seed * iteration, 13))
    );
    noStroke();
    rect(
      lerpX(noise(seed * iteration * 211)),
      lerpY(noise(seed * iteration * 212)),
      lerpW(noise(seed * iteration * 213)),
      lerpH(noise(seed * iteration * 214))
    );
    noFill();
  }
}


class ShowVideoStep implements Step {
  String[] fileList;
  int lastIteration;
  GLMovie movie;
  float seed;
  PApplet parent;

  void setup(PApplet parent) {
    this.seed = random(1);
    this.lastIteration = -1;
    this.fileList = new String[] {
      "william-2.mov",
      "dba-fw-1.mov",
      "meris-enzo-1.mov",
      "eae-1.mov",
      "hovercat-3.mov",
      "eae-2.mov",
      "hovercat-1.mov",
      "alvin-1.mov",
      "rainger-1.mov",
      "voland-ed-1.mov",
      "keir-1.mov"
    };
    this.movie = null;
    this.parent = parent;
  }

  void run(float playhead, int iteration) {
    clear();
    if (this.movie == null || this.lastIteration != iteration) {
      if (this.movie != null) {
        this.movie.close();
      }

      int pathInd = round(
        noise(iteration * 10, this.seed) * fileList.length
      );
      String path = this.fileList[pathInd];
      this.movie = new GLMovie(this.parent, path);
      this.movie.loop();
      this.movie.speed(1.0 + noise(iteration * this.seed));
      this.lastIteration = iteration;
    }

    if (!this.movie.available()) {
      return;
    }

    this.movie.read();

    // float glitch = round(playhead * 100.0) / 100.0;
    // this.movie.jump(noise(iteration, glitch) * movie.duration());
    tint(noise(seed * iteration) * 100, 100, 100);
    image(
      this.movie,
      (width - 2 * this.movie.width) / 2,
      (height - 2 * this.movie.height) / 2,
      2 * this.movie.width,
      2 * this.movie.height
    );
    noTint();
  }

}

String[] EVENTS = new String[] {
  "08.09 16:00 – DIYDay Electronics Co-working",
  "10.09 12:00 – Builders Circuit Meetup #1",
  "12.09 12:00 – Set up your guitar with Ruby Guitars",
  "15.09 16:00 – DIYDay Electronics Co-working",
  "22.09 16:00 – DIYDay Electronics Co-working",
  "25.09 15:00 – Build your synth with Error Instruments",
  "25.09 18:00 – [Ge]narrative exhibition opening",
  "29.09 16:00 – DIYDay Electronics Co-working",
};

class TextStep implements Step {

  float seed;

  void setup(PApplet parent) {
    this.seed = random(1);
  }

  void run(float playhead, int iteration) {
    clear();
    noStroke();
    color c = genBrightColor(noise(seed * iteration, 11));
    fill(c);

    textSize(30);

    text(
      "Events in September",
      lerpX(0.06),
      lerpY(0.15)
    );

    float y = 0.2;
    float yInc = 0.06;

    for (String event : EVENTS) {
      textSize(21);

      text(
        event,
        lerpX(0.06),
        lerpY(y += yInc)
      );
    }
  }
}
