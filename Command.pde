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
  cmdStrings.append(cmdLine);
  cmdLine="";
}

void getHist(int dir) {
  pcmd=min(max(dir+pcmd, 0), cmdStrings.size());
  if (pcmd==0) {
    cmdLine="";
  } else {
    cmdLine=cmdStrings.get(cmdStrings.size()-(pcmd));
  }
}

void drawCmd(){
  noStroke();
  fill(0);
  rect(0,0,300,20);
  //stroke(60,30,90);
  fill(255);
  String cursor="";
  if((frameCount/60)%2==0)cursor="|";
  text(">"+cmdLine+cursor, 5,15);
}
