import java.awt.*;
import java.awt.event.*;
//--------------------------------------------------------------------------------
//--------------------------------MAIN  TAB---------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//

Robot robot;
int starting = 40;
int Gfade = 10; 
int tick=0;
int size = 100;
public ArrayList<People> population;
PGraphics GUI;
PGraphics PG;
void setup() {
  size(1280, 755, P2D);
  try { 
    robot = new Robot();
    robot.setAutoDelay(0);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  background(0,12,12);
  //config peepl graphics
  PG=createGraphics(displayWidth,displayHeight,P2D);
  PG.beginDraw();
  PG.noStroke();
  PG.colorMode(HSB);
  PG.smooth(8);
  PG.endDraw();
  frameRate(1000000);
  population = new ArrayList<People>();
  frame.setResizable(true);
  GUI=createGraphics(displayWidth,displayHeight);
  for (int i = 0; i < starting; i++) {
    mkPeep();
  }
}

void draw() {
  frame.setTitle("People: "+population.size()+"  FPS: "+nf(frameRate,4,1));
  tick++;
  background(0);
  PG.beginDraw();
  PG.fill(0, Gfade);
  PG.rect(0, 0, width, height);
  for (int i = population.size () - 1; i > -1; i--) {
    People person = population.get(i);
    boolean is_dead = person.life(i);
    if (!is_dead) {
      population.remove(i);
    }
  }
  PG.endDraw();
  image(PG,0,0);
  drawCmd();
  drawMenu();
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
      fade=255;
    }
  }
  if (keyCode==DOWN)getHist(-1);
  if (keyCode==UP)getHist(1);
}

