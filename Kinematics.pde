/**
 *
 */

class Kinematics 
{
  PVector pos;
  PVector vel;
  float or;
  float rot;
  
  Kinematics(int x, int y) 
  {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    or = 0;
    rot = 0;
  }
}