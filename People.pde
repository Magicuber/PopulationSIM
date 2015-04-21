//--------------------------------------------------------------------------------
//--------------------------------CLASS TAB--------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
class People {
  int start_tick;
  int kolor = 0; 
  int lifeEX = 0;
  int typeA = 0;
  int typeB = 0;
  int typeC = 0;
  boolean alive = true;
  
  final int LIFETIME=1000;
  
  int state=0; //MOVING, the default
  int cooldown=200; //Used to keep them from spamming kids. Starts at 200 cause we don't want the kids banging each other
  final int STD_CD=100; //standard cooldoun ticks
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
  
  People(float _x, float _y, int _t,float _g, int _a, int _b, int _c) {
    x = _x;
    y = _y;
    start_tick = _t;
    lifeEX = _t + floor(random(-100,200));
    generation=_g;
    typeA = _a;
    typeB = _b;
    typeC = _c;
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
    People peep=new People((x+bro.x)/2, (y+bro.y)/2, tick,(generation+bro.generation)/2f+1f, (typeA+bro.typeA)/2+1, (typeB+bro.typeB)/2+1, (typeC+bro.typeC)/2+1);
    Population.add(peep);
  }
  
  void interact_scan(int i) { //Gets own id number
    //checks all previous people

    for (i=i-1; i > -1; i--) {
      People person = (People) Population.get(i);
      if (person.cooldown<1) {
        float dist=dist(x, y, person.x, person.y);
        float K=(clamp(0, INTER_DIST, INTER_DIST-dist)/INTER_K) * map(Population.size(),0,1000,1.5f,0.1f);
        if (K>random(1)) {
          state=INTERACTING;
          bro=person;
          bro.state=INTERACTED;
          break;
        }
      }
    }
  }
  
  void interact(){
    if(0.01<random(1)){
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
      fill((generation*50)%255,255,255);
      ellipse(x, y, 20, 20);
    }
  }

  private PVector vecNoise(PVector coords) {
    //Accepts PVector of noise coords, and returns PVector of noise in [-PEEP_SPEED, PEEP_SPEED]
    return PVector.mult(new PVector(noise(coords.x)-0.5f, noise(coords.y)-0.5f), 2*SHEEP_SPEED);
  }
}

float clamp(float min, float max, float val) {
  return max(min, min(max, val));
}

