//--------------------------------------------------------------------------------
//--------------------------------CLASS TAB---------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//
float clamp(float min, float max, float val) {
  return max(min, min(max, val));
}

void mkPeep() {
  People person = new People(random(0, width), random(0, height), tick, 1, floor(random(0, 10)), floor(random(0, 10)), floor(random(0, 10)), random(0,1));
  Population.add(person);
}

