/**
 * Bubble.pde
 *
 * @author: https://github.com/dasl-/my-life-aquatic
 * @version: 07/07/2012
 */

class Bubble extends Kinematics 
{
    float diameter;
    color mainColor;
    float maxSpeed;

    Bubble(color c) 
    {
        super(0,0); //0.8, 0.2, new PVector(0, -1)); 
        pos = new PVector(int(random(width)), height);
        diameter = int(random(30, 50));
        maxSpeed = 1;
        mainColor = c;
        vel.x = 0;
        vel.y = -1;
    }

    void render() 
    {
        stroke(mainColor);
        strokeWeight(3);
        noFill();
        pushMatrix();
        translate(pos.x,pos.y);
        ellipseMode(CENTER);
        ellipse(0, 0, diameter, diameter);
        popMatrix();
    }

    void update() 
    {
      vel.x = random(-0.4, 0.4);
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
    }
    
    float scale(float a, float b) 
    {
      boolean is_neg = a < 0;
      a = min(abs(a), b);
      if(is_neg) a *= -1;
      return a;
    }
}