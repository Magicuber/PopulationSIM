//--------------------------------------------------------------------------------
//--------------------------------GENE TAB----------------------------------------
//--------------------------------------------------------------------------------
//This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
//Anthony Catalano-Johnson//
//Benjamin Welsh//

// Genes are an atripute class that will eventually be able to mutate.

class Gene{
  float val;
  float INTERACT_WEIGHT=0.01f;
  Gene(float value){
    val=value;
  }

  void interact(Gene other){
    other.val+=val/INTERACT_WEIGHT;
    val+=other.val/INTERACT_WEIGHT;
  }
}
