public class Reel
{
  //public float delta;
  //public float deltaDegree;
  public boolean rotationComplete;
  //public int rotatedPreFrame;
  //private int lastRotated;
  //private int rotatedDeg;
  private float targetAngle;
  private int duration;
  
  public Reel(){
    this.rotationComplete = false;
    this.targetAngle = 0;
    this.duration = 10;
  }
  
  // rotate until the target height is reached
  // return true if it has been reached
  // return false if it has not been completed
  /*
  public boolean rotateByHeight(int id, float neededDegree) {
    // need = the amount of degree rotation needed?
    // dir = direction of left or right rotation
    int dir = (neededDegree > 0) ? 1 : -1;
    //println(need);
    float strength = neededDegree / 14; // used to be 14
    float left =  4 * (strength); // used to be 6
    float right = -4 * (strength);

    if (abs(neededDegree) < 3 || abs(left) < 10) return true; // used to be 3
    //println("motorControl:", "need: " need);

    float max = 70;
    //use map(value, 0, max, 0, 115)?
    if (abs(left) > max ) left = dir * max; // why max? why not 115? now: 60
    if (abs(right) > max ) right = -dir * max;
    //if (abs(left) > max ) left = -dir * max; // why max? why not 115? now: 60
    //if (abs(right) > max ) right = dir * max;
    this.targetAngle = 
    int duration = 10; // used to be 100
    
    motorControl(targetAngle, duration);
    return false;
  }
  */
  
  // send targetAngle to Arduino Atom
  public void reelingMotorControl(){
  }
  
  //public void setAsRotating() {
  //  rotatedPreFrame = this.rotatedDeg - lastRotated; // note rotatedDeg is also updated in server_rece_cmd.pde
  //  lastRotated = this.rotatedDeg;
  //}
  
  //public void setAsCompleted() {
  //  this.rotatedDeg = 0;
  //  this.lastRotated = 0;
  //  this.rotationComplete = true;
  //}
}
