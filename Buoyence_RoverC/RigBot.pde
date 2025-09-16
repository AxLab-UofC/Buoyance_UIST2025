/*
RigBot --(uses)--> OmniBot
RigBot --(uses)--> Reel
*/
//Parses and updates the information for the robot from unity

public class RigBot
{
  public int id;
  public OmniBot omnibot;
  public Reel reel;
  private ConnectionPoint linkedPoint;
  private boolean isActive;
  private PVector offset;
  
  public RigBot(int id, boolean isActive, OmniBot omnibot, Reel reel)
  {
    this.id = id;
    this.omnibot = omnibot;
    this.reel = reel;
    this.linkedPoint = null;
    this.isActive = isActive;
    this.offset = new PVector(0,0);
  }
  /* -------------------------------------------------------------------------- */
  /*                       Rigbot update functions                              */
  /* -------------------------------------------------------------------------- */
  
   /*
    * ensures that the hypotenuse remains the same length
    * updates offsetX, offsetY based on the hypotenuse and objectCenter
    * @param  x:  cp.getCenter().x - objectCenter.x;
   */
  public void updateOffset(float offset, float x, float y) {
    if (x == 0 && y == 0) {
      this.offset = new PVector(0,0);
      return;
    }
    float hypotenuse = sqrt(x * x + y * y);
    // calculate offsetX and offsetY with theta and offset value
    this.offset.x = offset * x/hypotenuse;
    this.offset.y = offset * y/hypotenuse;
  }

  /*
  * This updates the (x,y,z) of the bot to the target coords based on new (x,y,z), stringAngle and newoffset
  */
  public void updateXYZ(PVector targetPoint){ 
    if(targetingMode){
      if(this.isActive){
        //omnibot.setTargetPosition(targetPoint.copy().add(this.offset));
        if(lifting[selectedObject] == 1){
          omnibot.setTargetPosition(new PVector(targetPoint.x, targetPoint.y, targetPoint.z - botHeight));
        }else{
          omnibot.setTargetPosition(new PVector(targetPoint.x, targetPoint.y));
        }
        omnibot.setTargetSet(true);
        omnibot.initPID();
      }
    }else{
      if(!trackingMode){
        PVector cpCenter = this.getLinkedPoint().getCenter().copy();
        if(lifting[selectedObject] == 1){
          this.omnibot.setPosition(new PVector(cpCenter.x, cpCenter.y, cpCenter.z - botHeight));
        }else{
          this.omnibot.setPosition(new PVector(cpCenter.x, cpCenter.y, 0.0));
        }
      }
      omnibot.setTargetSet(false);
    }
    //will only pass the assigned cubes data here to update them
    pushMatrix();
    
    // update the string bot by z-coord changes
    float targetStrlen = sqrt(sq(targetPoint.z - botHeight));
    //print(targetStrlen);
    if(targetStrlen< mmToToio) targetStrlen = 0;
    
    if(lifting[selectedObject] == 1){
      targetStrlen = 0;
    }
    //println(this.id + " " + linkedPoint.strlen + " " + targetStrlen);

    //reel.delta = - linkedPoint.strlen + targetStrlen; //+ down, - up
    this.reel.targetAngle = targetStrlen/spinR;
    //println(reel.targetAngle);
    this.reel.rotationComplete = false;

    //if(abs(reel.delta)> 0){
    //  reel.rotationComplete = false;
    //  reel.deltaDegree = reel.delta/spinR;
    //}
    popMatrix();
  }
  
  /* -------------------------------------------------------------------------- */
  /*                       Rigbot move functions                                */
  /* -------------------------------------------------------------------------- */
  /*
  public void rotateSpool() {
    
    if(!reel.rotationComplete) {
      // rotateByHeight returns true if rotation is complete
      //println("!!!!!!!!!delta:" + stringCube.deltaDegree);
      // if rotation is complete
      if(reel.rotateByHeight(this.id, reel.deltaDegree)) { 
        //reel.setAsCompleted();
        reel.rotationComplete = true;
        linkedPoint.strlen = sqrt(sq(linkedPoint.getCenter().z -botHeight)); // computes the expected strlen
        println("finish rotating!"+linkedPoint.strlen);
        return;
      }
      // if rotation is not complete
      //reel.setAsRotating();
      // println("rig bot rotatedDeg: " + cubes[1].rotatedDeg);
     // linkedPoint.strlen += reel.rotatedPreFrame * spinR;
      // println("linkedPoint.strlen: " + linkedPoint.strlen + ", stringCube.rotatedPreFrame: " + stringCube.rotatedPreFrame);
    }
  }
  */

  /* -------------------------------------------------------------------------- */
  /*                       Rigbot simulation functions                          */
  /* -------------------------------------------------------------------------- */
  /*
  * This updates the x,y,z of the connection point to the target coords in simulation
  * this only updates for translation, no rotation changes
  */
  private void updateSimXYZ(PVector targetPoint){
    pushMatrix();
    omnibot.target = targetPoint;
    omnibot.setTargetSet(true);
    omnibot.initPID();
    popMatrix();
  }
  /* -------------------------------------------------------------------------- */
  /*             getter, setter, and helper functions                           */
  /* -------------------------------------------------------------------------- */
  public ConnectionPoint getLinkedPoint(){
    if (this.linkedPoint == null)
    {
      return null;
    }
    return this.linkedPoint;
  }

  public void setLinkedPoint(ConnectionPoint linkedPoint){
    this.linkedPoint = linkedPoint;
  }  

}
