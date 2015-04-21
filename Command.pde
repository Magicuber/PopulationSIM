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
    if (cmds[0].equals("clear")) {
      Population = new ArrayList();
      println("clear");
    }
  }
  if (cmds.length==2) {
    if (cmds[0].equals("addpeeps")) {
      for (int i=0; i<int (cmds[1]); i++) {
        mkPeep();
      }
    }
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

void drawCmd() {
  noStroke(); 
  fill(0); 
  rect(0, 0, 300, 20); 
  //stroke(60,30,90);
  fill(255); 
  String cursor=""; 
  if ((frameCount/60)%2==0)cursor="|"; 
  text(">"+cmdLine+cursor, 5, 15);
}

