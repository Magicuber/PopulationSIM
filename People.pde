//--------------------------------------------------------------------------------
//--------------------------------CLASS TAB--------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
class People {
  int start_tick;
  boolean alive = true;

  //Movement
  float x;
  float y;
  PVector noisePosition = new PVector(random(100000), random(100000)); // Position in the Noise
  final private PVector N_MOVE=new PVector(0.01, 0.01); // This sets the speed to move across the Perlin Noise.
  float SHEEP_SPEED=2f;  //Coefficient of moving

  People(float _x, float _y, int _t) {
    x = _x;
    y = _y;
    start_tick = _t;
  } 

  boolean life() {
    display();
    move();
    wrap();
    baby();
    return death();
  }

  boolean death() {
    if ((tick - start_tick) > 500) {
      alive = false;
      return false;
    } else {
      return true;
    }
  }


  void baby() {
  }

  void wrap() {
    if (x > width) {
      x = x - width;
    } else if (x < 0) {
      x = x + width;
    }
    if (y > height) {
      y = y - height;
    } else if (y < 0) {
      y = y + height;
    }
  }

  void move() {
    PVector v = vecNoise(noisePosition);
    noisePosition.add(N_MOVE);
    x +=v.x;
    y +=v.y;
  }

  void display() {
    if (alive == true) { 
      ellipse(x, y, 30, 30);
    }
  }

  private PVector vecNoise(PVector coords) {
    //Accepts PVector of noise coords, and returns PVector of noise in [-PEEP_SPEED, PEEP_SPEED]
    return PVector.mult(new PVector(noise(coords.x)-0.5f, noise(coords.y)-0.5f), 2*SHEEP_SPEED);
  }
}

