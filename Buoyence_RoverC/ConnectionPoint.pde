/*
 * This class defines a connection point for an object in space
 * each connection point is mapped one-to-one to a RigBot
 * connection points are instantiated using existing connection points and distances from each other
*/
//https://happycoding.io/tutorials/java/inheritance

// Connection point for a cube.

///** TEMPLATE (because different move types) **///
public class ConnectionPoint {
  public int id;
  public PVector center;
  public PVector init;
  public RigBot bot; // the bot that this connection point is linked to; null if not linked
  public float strlen;  // String length

/*
* This instantiates a connection point from an arbitrary point
* @param point determines the center of the connection point
*/
  public ConnectionPoint(int id, PVector point, RigBot bot)
  {
    this.id = id;
    this.center = point;
    this.bot = bot;
    this.bot.setLinkedPoint(this);
    this.strlen = this.center.z - botHeight;
    if(this.strlen<0) this.strlen = 0;
    this.init = new PVector(this.center.x, this.center.y, this.center.z);
  }

/*
* This instantiates a connection point a horizontal distance from an existing connection point
* @param dist determines the distance from the existing connection point
*/
  public ConnectionPoint(int id, ConnectionPoint cp, int dist, RigBot bot)
  {
    this.id = id;
    this.center = new PVector(cp.center.x + dist, cp.center.y, cp.center.z); // assume string is wound up all the way (z = hs)
    this.bot = bot;
    this.bot.setLinkedPoint(this);
    this.strlen = this.center.z - botHeight;
     if(this.strlen<0) this.strlen = 0;
     this.init = new PVector(this.center.x, this.center.y, this.center.z);

  }

  /*
  * This instantiates a connection point from two existing HORIZONTAL connection points
  * @param dist1 determines the distance from the cp1 to the new cp
  * @param dist2 determines the distance from the cp2 to the new cp
  *           [X] current cp
  *           / \
  *          /   \  dist 2
  *   dist1 /     \
  *        /       \
  *  cp1 [X]-------[X] cp2 (cp2 must be to the RIGHT of cp1)
  */
  public ConnectionPoint(int id, ConnectionPoint cp1, ConnectionPoint cp2, int dist1, int dist2, RigBot bot)
  {

    this.id = id;
    this.bot = bot;
    this.bot.setLinkedPoint(this);

    if(this.strlen<0) this.strlen = 0;

    float d = cp2.center.x - cp1.center.x; // distance between cp1 and cp2
    float x = (sq(d) - sq(dist2) + sq(dist1)) / (2 * d);
    float y = cp2.center.y + sqrt(sq(dist1) - sq(x));

    this.center = new PVector((int)x + cp1.center.x, (int) y, cp1.center.z);
    this.strlen = this.center.z - botHeight;
    if(this.strlen<0) this.strlen = 0;
    this.init = new PVector(this.center.x, this.center.y, this.center.z);
  }

  ///*** getters and setters ***///

  public PVector getCenter()
  {
    return this.center;
  }

  public RigBot getBot()
  {
    return this.bot;
  }
  
  ///*** methods ***///

  public void translatePoint(PVector dist)
  {
    this.center.add(dist);
  }

  public void rotatePoint(float newyaw, float newroll, float newpitch, PVector pivot, float yaw, float slopeAngle)
  {
     
    // yaw
    if(abs(newyaw) > 5) {
      PVector diff = this.center.copy().sub(pivot);
      //PVector yawDiff = diff.copy().rotate(radians(newyaw));
      PVector yawDiff = diff.copy();
      yawDiff.x = (diff.x * cos(radians(newyaw))) - (diff.y * sin(radians(newyaw)));
      yawDiff.y = (diff.x * sin(radians(newyaw))) + (diff.y * cos(radians(newyaw)));
      this.center = yawDiff.add(pivot);
    }
    
    // roll
    if(abs(newroll) > 5) {
      PVector diff = this.center.copy().sub(pivot);
      PVector rollDiff = diff.copy();
      rollDiff.x  = (diff.x * cos(radians(yaw+slopeAngle))) + (diff.y * sin(radians(yaw+slopeAngle)));
      rollDiff.y = - (diff.x * sin(radians(yaw+slopeAngle))) + (diff.y * cos(radians(yaw+slopeAngle)));
      diff = rollDiff.copy();
      rollDiff.y = (diff.y * cos(radians(newroll))) - (diff.z * sin(radians(newroll)));
      rollDiff.z = (diff.y * sin(radians(newroll))) + (diff.z * cos(radians(newroll)));
      diff = rollDiff.copy();
      rollDiff.x  = (diff.x * cos(radians(yaw+slopeAngle))) - (diff.y * sin(radians(yaw+slopeAngle)));
      rollDiff.y =  (diff.x * sin(radians(yaw+slopeAngle))) + (diff.y * cos(radians(yaw+slopeAngle)));
      this.center = rollDiff.add(pivot);
    }
    
    //pitch
    if(abs(newpitch) > 5) {
      PVector diff = this.center.copy().sub(pivot);
      PVector pitchDiff = diff.copy();
      pitchDiff.x  = (diff.x * cos(radians(yaw+slopeAngle))) + (diff.y * sin(radians(yaw+slopeAngle)));
      pitchDiff.y = - (diff.x * sin(radians(yaw+slopeAngle))) + (diff.y * cos(radians(yaw+slopeAngle)));
      diff = pitchDiff.copy();
      pitchDiff.x = (diff.x * cos(radians(newpitch))) + (diff.z * sin(radians(newpitch)));
      pitchDiff.z = - (diff.x * sin(radians(newpitch))) + (diff.z * cos(radians(newpitch)));
      diff = pitchDiff.copy();
      pitchDiff.x  = (diff.x * cos(radians(yaw+slopeAngle))) - (diff.y * sin(radians(yaw+slopeAngle)));
      pitchDiff.y =  (diff.x * sin(radians(yaw+slopeAngle))) + (diff.y * cos(radians(yaw+slopeAngle)));
      this.center = pitchDiff.add(pivot);
    }
  }
}
