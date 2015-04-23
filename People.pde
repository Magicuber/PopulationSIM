//--------------------------------------------------------------------------------
//--------------------------------PEOPLE TAB--------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//
class People {
  int start_tick;
  int kolor = 0; 
  int lifeEX = 0;
  float typeA = 0f;
  float typeB = 0f;
  float typeC = 0f;
  boolean alive = true;

  Gene resistance=new Gene(random(1));
  Gene infection=new Gene(0f);

  final int LIFETIME=1000;

  int state=0; //MOVING, the default
  int cooldown=200; //Used to keep them from spamming kids. Starts at 200 cause we don't want the kids banging each other
  final int STD_CD=100; //standard cooldown ticks
  float generation;
  People bro; //This is the guy we is interacting with

  //Movement
  float x;
  float y;
  PVector noisePosition = new PVector(random(100000), random(100000)); // Position in the Noise
  final private PVector N_MOVE=new PVector(0.01, 0.01); // This sets the speed to move across the Perlin Noise.
  float SHEEP_SPEED=2f;  //Coefficient of moving

  final private int MOVING=0;
  final private int INTERACTING=1;
  final private int INTERACTED=2;  //Someone else is interacting with us

  final float INTER_DIST=24;
  final float INTER_K=20;

  People() {
    x = random(0, width);
    y = random(0, height);
    start_tick = 0;
    lifeEX = 0 + floor(random(-100, 200));
    generation=1;
    typeA = 0;
    typeB = 0;
    typeC = 0;
  }

  People(float _x, float _y, int _t, float _g) {
    x = _x;
    y = _y;
    start_tick = _t;
    lifeEX = _t + floor(random(-100, 200));
    generation=_g;
    typeA = 0;
    typeB = 0;
    typeC = 0;
  }

  People(float _x, float _y, int _t, float _g, int _a, int _b, int _c) {
    x = _x;
    y = _y;
    start_tick = _t;
    lifeEX = _t + floor(random(-100, 200));
    generation=_g;
    typeA = _a;
    typeB = _b;
    typeC = _c;
  } 

  People(People p1, People p2) {
    x=(p1.x+p2.x)/2;
    y=(p1.y+p2.y)/2;
    start_tick=tick;
    lifeEX = tick + floor(random(-100, 200));
    generation=(p1.generation+p2.generation)/2f+1f;
    typeA=(p1.typeA+p2.typeA)/2+floor(random(-3, 3));
    typeB=(p1.typeB+p2.typeB)/2+floor(random(-3, 3));
    typeC=(p1.typeC+p2.typeC)/2+floor(random(-3, 3));
  }

  boolean life(int id) {
    display();
    if (state==MOVING) {
      move();
      wrap();
      social(id); //Interactions
    }
    if (state==INTERACTING) {
      interact();
    }
    if (state==INTERACTED) {
      //do nothing
    }
    return death();
  }

  boolean death() {
    if ((tick - lifeEX) > LIFETIME) {
      alive = false;
      return false;
    } else {
      return true;
    }
  }

  void social(int id) {
    if (cooldown<1) {
      interact_scan(id);
    } else {
      cooldown--;
    }
  }

  void baby() {
    //People peep=new People((x+bro.x)/2, (y+bro.y)/2, tick, (generation+bro.generation)/2f+1f, (typeA+bro.typeA)/2+floor(random(-3, 3)), (typeB+bro.typeB)/2+floor(random(-3, 3)), (typeC+bro.typeC)/2+floor(random(-3, 3)));
    population.add(new People(bro,this));
  }

  void interact_scan(int i) { //Gets own id number
    //checks all previous people

    for (i=i-1; i > -1; i--) {
      People person = population.get(i);
      if (person.cooldown<1) {
        float dist=dist(x, y, person.x, person.y);
        float K=(clamp(0, INTER_DIST, INTER_DIST-dist)/INTER_K) * map(population.size(), 0, 100000, 1.5f, 0.1f);
        if (K>random(1)) {
          state=INTERACTING;
          bro=person;
          bro.state=INTERACTED;
          break;
        }
      }
    }
  }

  void interact() {
    if (0.01<random(1)) {
      baby();
      state=MOVING;
      bro.state=MOVING;
      bro.cooldown=STD_CD;
      cooldown=STD_CD;
      bro=null;
    }
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
      fill((generation*50)%255, 255, 255);
      ellipse(x, y, 5, 5);
    }
  }

  private PVector vecNoise(PVector coords) {
    //Accepts PVector of noise coords, and returns PVector of noise in [-PEEP_SPEED, PEEP_SPEED]
    return PVector.mult(new PVector(noise(coords.x)-0.5f, noise(coords.y)-0.5f), 2*SHEEP_SPEED);
  }
}

