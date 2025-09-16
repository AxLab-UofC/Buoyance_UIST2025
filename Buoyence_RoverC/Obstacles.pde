public class Obstacles
{
  private PVector position;
  private PVector velocity;
  private float yaw;
  private float size;
  private boolean appear;
  
  //constructor
  public Obstacles(){
    this.position = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    //this.angle = new PVector(0.0,0.0);
    this.yaw = 0;
    this.appear = false;
  }
  
  //setter
  public void setPosition(PVector position){this.position = position;}
  public void setVelocity(PVector velocity) {this.velocity = velocity;}
  public void setAngle(float yaw){this.yaw = yaw;}
  
  //getter
  public PVector getPosition(){return position;}
}
