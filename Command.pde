//--------------------------------------------------------------------------------
//--------------------------------COMMAND TAB-------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//

StringList cmdStrings = new StringList();
String cmdLine="";
int pcmd=0;

void doCmd() {
  String[] cmds=cmdLine.split(" ");
  cmdStrings.append(cmdLine);
  cmdLine="";
  if (cmds.length==1) {
    if (cmds[0].equals("help")) {
      printc("Commands: [clear: kill everyone][add n: add n people]");
    } else if (cmds[0].equals("clear")) {
      population = new ArrayList<People>();
      printc("Cleared Population (Genocide)");
    } else  printc("Unrecognised command. Type 'help' for list of commands.", 255);
  } else if (cmds.length==2) {
    if (cmds[0].equals("add")) {
      printc("Made "+str(int(cmds[1]))+" new people.");
      for (int i=0; i<int (cmds[1]); i++) {
        mkPeep();
      }
    } else if (cmds[0].equals("kill")) {
      for (int i=0; i<int (cmds[1]); i++) {
        klPeep();
      }
    } else printc("Unrecognised command. Type 'help' for list of commands.", 255);
  } else {
    printc("Unrecognised command. Type 'help' for list of commands.", 255);
  }
}

void getHist(int dir) {
  pcmd=min(max(dir+pcmd, 0), cmdStrings.size()); 
  if (pcmd==0) {
    cmdLine="";
  } else {
    cmdLine=cmdStrings.get(cmdStrings.size()-(pcmd));
  }
}

float fade=0;
void drawCmd() {
  GUI.beginDraw();
  GUI.colorMode(HSB);
  GUI.rect(0, 0, width, height);
  GUI.background(0, 0);
  GUI.noStroke(); 
  GUI.fill(0, fade); 
  GUI.rect(0, 0, 450, 40); 
  //stroke(60,30,90);
  GUI.fill(255); 
  String cursor=""; 
  if ((frameCount/60)%2==0)cursor="|"; 
  GUI.text(">"+cmdLine+cursor, 5, 15);
  GUI.fill(red, 255, 255);
  GUI.text(cmsg, 5, 35);
  fade=max(0, fade-1);
  GUI.endDraw();
  image(GUI, 0, 0);
}


///// printc

float red=0;
String cmsg="";
void printc(String msg) {
  red=0;
  fade=255;
  cmsg=msg;
}
void printc(String msg, float _red) {
  red=_red;
  fade=255;
  cmsg=msg;
}

