//--------------------------------------------------------------------------------
//--------------------------------MAIN  TAB---------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//

/*-----------ChangeLog-----------
<<<<<<< HEAD
 Change(B): To make system more general, I've switched it to use a tick counter in place of frame counter.
 Request(B): can we call People.torus People.wrap? I think it'd be easier to recognise its purpose.
=======

>>>>>>> master
 -------------------------------*/
float n = 2;
int starting = 100;
int p = 10; 
int tick=0;
public ArrayList Population;
public ArrayList<PVector> Generation = (ArrayList<PVector>) new ArrayList[];
void setup() {
  size(1280, 755);
  noStroke();
  smooth(8);
  frameRate(1000000);
  Population = new ArrayList();
  for (int i = 0; i < starting; i++) {
    People Person = new People(random(0, width), random(0, height), tick);
    Population.add(Person);
    fill(30, 60, 90);
  }
}

void draw() {
  tick++;
  fill(0, p);
  rect(0, 0, width, height);
  //background(0);
  People Person = new People(random(0, width), random(0, height), tick);
  Population.add(Person);

  for (int i = Population.size () - 1; i > -1; i--) {
    People Person2 = (People) Population.get(i);
    Person2.life();
    fill(30 - frameCount, 60 + frameCount, 90 + frameCount);
    if (Person2.life() == false) {
      Population.remove(i);
    }
  }
<<<<<<< HEAD
=======
 /////////////////////////////////////////////////////////////////////////////// 
 for (int k = 0; k < Population.size (); k++) {
    if (Population.get(k)) {
      for (int i = 0; i < k; i++) {
        if (Population.get(i).move > Population.get(k).move) { // WHAT IS THIS??????
        }
      }
    }
  }
  // println(wi + " " + wk);
  /*for (int i = 0; i < Population.size (); i++) {
   for (int k = 0; k < Population.size (); k++) {
   if(Population.size(i) == Population.size(k)){
   fill(30, 60, 90);
   People Person = new People(random(0, width), random(0, height), tick);
   Population.add(Person);
   }
   }
   }*/
///////////////////////////////////////////////////////////////////////////////////
>>>>>>> master
  println(Population.size());
}

void VFill(int i) {  
  fill(30 - tick, 60 + tick, 90 + tick);  //breaks PVector 'v' to an array of floats to color circles 
}

