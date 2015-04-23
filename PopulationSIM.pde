//--------------------------------------------------------------------------------
//--------------------------------MAIN  TAB---------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//
int starting = 10;
int p = 10; 
int tick=0;
int size = 100;
public ArrayList<People> population;
PGraphics GUI;
void setup() {
  size(1280, 755, P2D);
  noStroke();
  colorMode(HSB);
  smooth(8);
  frameRate(1000000);
  population = new ArrayList<People>();
  frame.setResizable(true);
  GUI=createGraphics(displayWidth,displayHeight,P2D);
  for (int i = 0; i < starting; i++) {
    mkPeep();
  }
}

void draw() {
  frame.setTitle(str(frameRate));
  tick++;
  fill(0, p);
  rect(0, 0, width, height);
  //if (tick <= size) {
  //  People person = new People(random(0, width), random(0, height), tick, 1, floor(random(0,10)), floor(random(0,10)), floor(random(0,10)));
  //  Population.add(Person);
  //}
  for (int i = population.size () - 1; i > -1; i--) {
    People person = population.get(i);
    boolean is_dead = person.life(i);
    if (!is_dead) {
      population.remove(i);
    }
  }

  drawCmd();
  //println(Population.size())
}


void keyPressed() {
  println(keyCode);
  if (keyCode==8) {
    if (cmdLine.length()!=0) {
      cmdLine=cmdLine.substring(0, cmdLine.length()-1);
    }
  } else   if (key!=CODED) {
    if (key==ENTER) {
      doCmd();
    } else {
      cmdLine+=key;
    }
  }
  if (keyCode==DOWN)getHist(-1);
  if (keyCode==UP)getHist(1);
}

