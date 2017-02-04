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
    String id;
    float maxSpeed;

    Bubble(color c) 
    {
        super(0,0); //0.8, 0.2, new PVector(0, -1)); 
        pos = new PVector(int(random(0, width - 1)), height - 1);
        diameter = int(random(30, 50));
        maxSpeed = 1;
        mainColor = c;
        vel.x = 0;
        vel.y = -1;
    }

    void render() {
        smooth();
        stroke(mainColor);
        strokeWeight(3);
        noFill();
        ellipseMode(CENTER);
        ellipse(pos.x, pos.y, diameter, diameter);
    }

    void update() {
      vel.x = random(-0.4, 0.4);
      //super.update();
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