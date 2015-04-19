//--------------------------------------------------------------------------------
//--------------------------------MAIN  TAB---------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//

/*-----------ChangeLog-----------
 Change(B): To make system more general, I've switched it to use a tick counter in place of frame counter.
 Request(B): can we call People.torus People.wrap? I think it'd be easier to recognise its purpose.
 -------------------------------*/
float n = 2;
int starting = 100;
int p = 10; 
int tick=0;
public ArrayList Population;

public ArrayList<PVector> Generation = new ArrayList<PVector>();

void setup() {
  size(1280, 755);
  noStroke();
  colorMode(HSB);
  smooth(8);
  frameRate(1000000);
  Population = new ArrayList();
  for (int i = 0; i < starting; i++) {
    People Person = new People(random(0, width), random(0, height), tick,1);
    Population.add(Person);
    fill(30, 60, 90);
  }
}

void draw() {
  frame.setTitle(str(frameRate));
  tick++;
  fill(0, p);
  rect(0, 0, width, height);
  //background(0);
  //People Person = new People(random(0, width), random(0, height), tick,tick);
  //Population.add(Person);

  for (int i = Population.size () - 1; i > -1; i--) {
    People Person2 = (People) Population.get(i);
    boolean is_dead = Person2.life(i);
    //fill(30 - frameCount, 60 + frameCount, 90 + frameCount);
    if (!is_dead) {
      Population.remove(i);
    }
  }

  println(Population.size());
}

