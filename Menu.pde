//--------------------------------------------------------------------------------
//--------------------------------MENU TAB----------------------------------------
//--------------------------------------------------------------------------------
Point mousePoint;
MFloat Mfade=new MFloat(100, "Screen Fade", 1f);

void drawMenu() {
  GUI.beginDraw();
  GUI.fill(0, 200);
  GUI.stroke(100);
  GUI.rect(width-300, 0, 300, height);
  // Component drawing
  Mfade.draw(width-125);
  GUI.endDraw();
  doVals(); // Sets vals to controls
}

void doVals() {
  Gfade=(int)Mfade.val;
}

/*interface MControl {
  void draw(int x);
  void click(int mx, int my);
}*/
class MFloat extends MControl {
  float perPix; // Amount of change per pixel for dragging
  float val;
  MFloat(int y, String name, float perPix) {
    super(y,name);
    this.perPix = perPix;
  }

  void draw(int x){
    super.draw(x,str(val));
  }
  void drag(float mx){
    val+=perPix*mx;
  }
}

class MControl {
  int y;
  int x;
  void drag(float mx){} //Placeholder for drag functionality added by children.
  void click(){}// Placeholder for click functionality added by children.
  String name;

  MControl(int y, String name) {
    this.y=y;
    this.name=name;
  }
  void draw(int x,String val) {
    this.x=x;
    GUI.fill(0, 200);
    GUI.textSize(20);
    GUI.stroke(100);
    GUI.rect(x, y, 100, 25);
    GUI.fill(255);
    GUI.text(val, x+5, y+20);
    GUI.text(name, x-150, y+20);
  }
  void pressed(int mx, int my) {
    if (y<mouseY&&mouseY<y+25&&x<mouseX&&mouseX<x+100) {
      drag(float(mx));
    }
  }
  void clicked(){
    if (y<mouseY&&mouseY<y+25&&x<mouseX&&mouseX<x+100) {
      clicked();
    }
  }
}

void mouseClicked() {
  Mfade.clicked();
}
void mousePressed() {
  mousePoint=getGlobalMouseLocation();
  noCursor();
}
void mouseDragged() {
  int dx=(int)mousePoint.getX()-(int)getGlobalMouseLocation().getX();
  int dy=(int)mousePoint.getY()-(int)getGlobalMouseLocation().getY();
  Mfade.pressed(dx, dy);
  robot.mouseMove((int)mousePoint.getX(), (int)mousePoint.getY());
}
void mouseReleased() {
  cursor();
}

