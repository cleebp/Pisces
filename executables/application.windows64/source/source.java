import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class source extends PApplet {

/**
 * source.pde
 * 
 * @author: Brian Clee | bpclee@ncsu.edu
 */
 
public double worldStart;
public double elapsed10;
public double elapsed60;
String display;
PImage info;
//PFont font;
public int canvas_x = 0;
public int canvas_y = 0;
public int canvas_height = 0;

Fish[] fishList;
Shark bruce;
Dolphin[] dolphins;

int modifier;
int trails = 69; // original 20, higher = less trail
int[] leaders;

ArrayList<Bubble> foregroundBubbles;
ArrayList<Bubble> backgroundBubbles; 

public void setup() 
{
  //start of our world
  worldStart = TimeUtil.systemSeconds();
  elapsed10 = worldStart;
  elapsed60 = worldStart;
  println("width = " + displayWidth);
  println("height = " + displayHeight);
  int numFish = 0;
  canvas_height = displayHeight;
  noCursor();
  
  if(displayWidth == 6816 || displayWidth == 3840)
  {
    //immersion theater
    display = "immersion";
    info = loadImage("info_immersion.png");
    modifier = 3;
    //canvas_x = 960;
    canvas_x = 985;
    numFish = 1100;
  }
  else if (displayWidth == 5760)
  {
    //artwall
    display = "artwall";
    info = loadImage("info_artwall.png");
    modifier = 3;
    //canvas_x = 960;
    canvas_x = 985;
    numFish = 1400;
  }
  else if (displayWidth == 2880)
  {
    //commons
    display = "commons";
    info = loadImage("info_commons.png");
    modifier = 3;
    //canvas_y = 400;
    canvas_height = 1980; //2400 - 420 = 1980, 2400 - 400 = 2400
    numFish = 1000;
  }
  else 
  {
    //macbook
    display = "macbook";
    info = loadImage("info_macbook.png");
    canvas_height = 680; //900 - 220 = 680, 900 - 200 = 700
    modifier = 1;
    numFish = 1000;
  }
  
  //font = createFont("Ariel",32,true);
  background(2, 37, 94);
  
  //size(1440,900,P3D);
  frameRate(30);
  
  //spawn a shark at a random point on the left side of the screen
  bruce = new Shark(canvas_y, PApplet.parseInt(random(height)));
  bruce.modifier = modifier;
  
  fishList = new Fish[numFish];
  leaders = new int[fishList.length/100];
  for(int i = 0; i < fishList.length; i++) 
  {
    int x = PApplet.parseInt(random(canvas_x, width));
    int y = PApplet.parseInt(random(canvas_y, height));
    fishList[i] = new Fish(x, y);
    fishList[i].targets = fishList;
    fishList[i].maxSpeed = random(1.5f) + 2.5f;
    //println("color: " + int(pow(fishList[i].maxSpeed, 4)));
    fishList[i].c = color(0, 0, PApplet.parseInt(random(155,235)));
    fishList[i].modifier = modifier;
  }
  
  for(int i = 0; i < leaders.length; i++)
  {
    int index = PApplet.parseInt(random(fishList.length));
    fishList[index].leader = true;
    fishList[index].c = color(0, 0, PApplet.parseInt(random(135,155)));
    fishList[index].maxSpeed = 2;
    leaders[i] = index;
  }
  
  dolphins = new Dolphin[5];
  for(int i = 0; i < dolphins.length; i++)
  {
    dolphins[i] = new Dolphin(canvas_y, PApplet.parseInt(random(height)));
    dolphins[i].maxSpeed = random(1.5f) + 3.5f;
    int purp = PApplet.parseInt(random(130,175));
    dolphins[i].c = color(purp,0,purp);
    dolphins[i].modifier = modifier;
  }
  
  foregroundBubbles = new ArrayList<Bubble>();
  backgroundBubbles = new ArrayList<Bubble>();
}

public void draw() 
{
  double currentTime = TimeUtil.systemSeconds();
  elapsed10 = currentTime - elapsed10;
  elapsed60 = currentTime - elapsed60;
  
  boolean ten = false;
  boolean sixty = false;
  //this actually happens every 20 seconds and 120 seconds because im capping at 30 fps... #featurenotabug
  if(elapsed10 > 10.0f && elapsed10 < 100)
  {
    print("10 seconds!");
    ten = true;
    elapsed10 = currentTime;
  }
  if(elapsed60 > 60.0f && elapsed60 < 100)
  {
    print("60 seconds!");
    sixty = true; 
    elapsed60 = currentTime;
  }
  
  if(display.equals("macbook") || display.equals("commons"))
  {
    image(info,0,canvas_height+20);
  }
  else
  {
    image(info,0,0);
  }
  // draws a semi-transparent rectangle over the window to create fading trails
  fill(2, 37, 94, trails);
  rect(0, 0, width, height);
  
  float randomNumber = random(0, 1000);

  //print fps top left
  //textFont(font,32);
  //fill(255);
  //text("FPS: " + frameRate,10,25);

  if(randomNumber > 980) 
  {
    Bubble newBub = new Bubble( color(PApplet.parseInt(random(100, 255)), 50));
    newBub.modifier = modifier;
    foregroundBubbles.add(newBub);
  }
  else if(randomNumber < 20)   
  {
    Bubble newBub = new Bubble( color(PApplet.parseInt(random(100, 255)), 50));
    newBub.modifier = modifier;
    backgroundBubbles.add(newBub);
  }

  for(int i = backgroundBubbles.size()-1; i >= 0; i--) 
  {
    Bubble bubble = backgroundBubbles.get(i);
    if (bubble.pos.y < -50)
      backgroundBubbles.remove(i);
    else 
    {
      bubble.update();
      bubble.render();
    }
  }
  
  // this logic could be cleaned up but you know whatever
  if(bruce.lives() && !dolphins[0].lives())
  {
    if(sixty)
    {
      PVector goal = new PVector(width, PApplet.parseInt(random(canvas_y,height)));
      for(int i = 0; i < dolphins.length; i++)
      {
        dolphins[i].goal.pos = goal;
        dolphins[i].spawn();
        dolphins[i].update();
        dolphins[i].display();
      }
      bruce.goal.pos = goal;
    }
    bruce.update();
    bruce.display();
  }
  else if(bruce.lives() && dolphins[0].lives())
  {
    if(bruce.update())
      bruce.display();
      
    for(int i = 0; i < dolphins.length; i++)
    {
      dolphins[i].update();
      dolphins[i].display();
    }
  }
  else if(!bruce.lives())
  {
    for(int i = 0; i < dolphins.length; i++)
    {
      if(dolphins[i].lives())
      {
        dolphins[i].update();
        dolphins[i].display();
      }
    }
    if (sixty)
    {
      bruce.revive();
      bruce.update();
      bruce.display();
    }
  }
  
  
  // every 20 seconds chose a new leader to follow
  if(ten && !dolphins[0].lives() && bruce.lives())
  {
    bruce.goal.pos = fishList[leaders[PApplet.parseInt(random(leaders.length))]].pos;
    bruce.update();
    bruce.display();
  }
  
  // every 10 seconds shuffle the leaders
  if(ten)
  {
    for(int i = 0; i < leaders.length; i++)
    {
      int index = leaders[i];
      fishList[index].leader = false;
      //fishList[index].c = color(0, 0, int(pow(fishList[i].maxSpeed, 4)));
      fishList[index].c = color(0, 0, PApplet.parseInt(random(155,235)));
      fishList[index].maxSpeed = random(1.5f) + 2.5f;
    }
    
    for(int i = 0; i < leaders.length; i++)
    {
      int index = PApplet.parseInt(random(fishList.length));
      fishList[index].leader = true;
      fishList[index].c = color(0, 0, PApplet.parseInt(random(135,155)));
      fishList[index].maxSpeed = 2;
      leaders[i] = index;
    }
  }
  
  for(int i = fishList.length-1; i >= 0; i--) 
  {
    fishList[i].update();
    fishList[i].display();
  }
  
  for(int i = foregroundBubbles.size()-1; i >= 0; i--) 
  {
    Bubble bubble = foregroundBubbles.get(i);
    if (bubble.pos.y < -50)
      foregroundBubbles.remove(i);
    else 
    {
      bubble.update();
      bubble.render();
    }
  }
}
/**
 * Bubble.pde
 *
 * @author: https://github.com/dasl-/my-life-aquatic
 * @version: 07/07/2012
 */

class Bubble extends Kinematics 
{
    float diameter;
    int mainColor;
    float maxSpeed;

    Bubble(int c) 
    {
        super(0,0); //0.8, 0.2, new PVector(0, -1)); 
        pos = new PVector(PApplet.parseInt(random(canvas_x,width)), height);
        diameter = PApplet.parseInt(random(30, 50));        
        maxSpeed = 1;
        mainColor = c;
        vel.x = 0;
        vel.y = -1;
    }

    public void render() 
    {
        stroke(mainColor);
        strokeWeight(3);
        noFill();
        pushMatrix();
        translate(pos.x,pos.y);
        ellipseMode(CENTER);
        ellipse(0, 0, diameter*modifier, diameter*modifier);
        popMatrix();
    }

    public void update() 
    {
      vel.x = random(-0.4f, 0.4f);
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
    }
    
    public float scale(float a, float b) 
    {
      boolean is_neg = a < 0;
      a = min(abs(a), b);
      if(is_neg) a *= -1;
      return a;
    }
}
/**
 * Dolphin.pde
 *
 * @author: Brian Clee
 */

class Dolphin extends Kinematics
{
  int c;
  float maxSpeed = 5;
  float maxRot = .005f;
  
  float maxAccel = .5f;
  float maxAngularAccel = 0.01f;
  
  float radiusOfSat = 100*modifier;
  float radiusOfDecel = 120;
  float radiusOfSat_rot = PI/32;
  float radiusOfDecel_rot = PI/4;
  
  PVector linear_acceleration;
  float angular_acceleration;
  
  float timeToTargetVelocity = 10;
  float timeToTargetRot = 10;
  
  Kinematics goal;
  Kinematics[] targets;
  
  boolean leader = false;
  boolean wander = false;
  
  long last_update;
  boolean exists;
  
  Dolphin(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(70, 0, 155);//(163, 0, 138);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);
    
    goal = new Kinematics(0, 0);
    last_update = millis();
    exists = false; // doesnt start spawned
  }
  
  // Update pos, vel, or
  public void update() 
  {
    if(!bruce.lives())
    {
      if(pos.x > width || pos.x < canvas_x || pos.y > canvas_height || pos.y < canvas_y) 
      {
        exists = false;
      }
      seekGoal();
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
      or = vel.heading();
      last_update = millis();
      return;
    }
    if(pos.x > width) 
    {
      pos.x = canvas_x;
    }
    if(pos.x < canvas_x) 
    {
      pos.x = width;
    }
    if(pos.y > canvas_height) 
    {
      pos.y = canvas_y;
    }
    if(pos.y < canvas_y) 
    {
      pos.y = canvas_height;
    }
    
    if(bruce.lives() && inRadius(bruce.pos)) 
    {
      avoid(bruce.pos);
    } 
    else if(!bruce.lives()) 
    {
      wander();
    } 
    else 
    {
      seekBruce();
    }
    
    float speed = scale(vel.mag(), maxSpeed);
    vel.normalize();
    vel.mult(speed);
    
    pos.add(vel);
    or = vel.heading();
    last_update = millis();
  }

  public void wander() 
  {
    long dtime = millis() - last_update;
    goal.or += maxRot * (random(1) - random(1)) * dtime * 3;       
    
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
    vel.x = cos(or);
    vel.y = sin(or);
    
    vel.normalize();
    vel.mult(maxSpeed);
  }
  
  public void seekBruce() 
  {
    PVector tar_pos = bruce.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    if(inRadius(tar_pos)) 
    {
      goalSpeed = maxSpeed * (distance/radiusOfDecel);
    } 
    else 
    {
      goalSpeed = maxSpeed;
    }
    
    goal.vel = direction;
    goal.vel.normalize();
    goal.vel.mult(goalSpeed);
    linear_acceleration.x = goal.vel.x - vel.x;
    linear_acceleration.y = goal.vel.y - vel.y;
    linear_acceleration.div(timeToTargetVelocity);
    
    vel.add(linear_acceleration);
    vel.normalize();
    vel.mult(goalSpeed);
    
    goal.or = vel.heading();
    
    if(abs(or - goal.or)%(2*PI) < radiusOfSat_rot) 
    {
      or = goal.or;
      return;
    }
       
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
  }
  
  public void seekGoal() 
  {
    PVector tar_pos = goal.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    //float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    goalSpeed = maxSpeed;
    
    goal.vel = direction;
    goal.vel.normalize();
    goal.vel.mult(goalSpeed);
    linear_acceleration.x = goal.vel.x - vel.x;
    linear_acceleration.y = goal.vel.y - vel.y;
    linear_acceleration.div(timeToTargetVelocity);
    
    vel.add(linear_acceleration);
    vel.normalize();
    vel.mult(goalSpeed);
    
    goal.or = vel.heading();
    
    if(abs(or - goal.or)%(2*PI) < radiusOfSat_rot) 
    {
      or = goal.or;
      return;
    }
       
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
  }
  
  public void avoid(PVector k) 
  {
    PVector tar_pos = k;
    linear_acceleration.x = pos.x - tar_pos.x;
    linear_acceleration.y = pos.y - tar_pos.y;
    linear_acceleration.normalize();
    linear_acceleration.mult(maxAccel);
      
    angular_acceleration = vel.heading();
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    vel.add(linear_acceleration);
  }
  
  public float scale(float a, float b) 
  {
    boolean is_neg = a < 0;
    a = min(abs(a), b);
    if(is_neg) a *= -1;
    return a;
  }
  
  public Kinematics getClosest(Kinematics given, Kinematics[] targetList) 
  {
    Kinematics closest = targetList[0];
    float closest_dist = dist(closest.pos.x, closest.pos.y, given.pos.x, given.pos.y);
    for(int i=0; i < targetList.length; i++) 
    {
      if(given == targetList[i]) 
        continue;
      float d = dist(targetList[i].pos.x, targetList[i].pos.y, given.pos.x, given.pos.y);
      if(d < closest_dist) 
      {
        closest = targetList[i];
        closest_dist = d;
      }
    }
    
    return closest;
  }

  private boolean inRadius(PVector t) 
  {
    return dist(pos.x, pos.y, t.x, t.y) < radiusOfSat;
  }
  
  public boolean lives()
  {
    return exists;
  }
  
  public void spawn()
  {
    exists = true;
    pos = new PVector(canvas_x, PApplet.parseInt(random(canvas_x,height)));
  }
  
  // Draw the fishy on the screen
  public void display() {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 30*modifier, 30*modifier);
    triangle(4.5f*modifier, -15*modifier, 30*modifier, 0, 4.5f*modifier, 15*modifier);
    popMatrix();
  }
}
/**
 * Fish.pde
 *
 * @author: Brian Clee
 */

class Fish extends Kinematics
{
  int c;
  float maxSpeed = 3;
  float maxRot = .005f;
  
  float maxAccel = .5f;
  float maxAngularAccel = 0.01f;
  
  float radiusOfSat = 20*modifier;
  float radiusOfDecel = 120;
  float radiusOfSat_rot = PI/32;
  float radiusOfDecel_rot = PI/4;
  
  PVector linear_acceleration;
  float angular_acceleration;
  
  float timeToTargetVelocity = 10;
  float timeToTargetRot = 10;
  
  Kinematics goal;
  Kinematics[] targets;
  
  boolean leader = false;
  boolean wander = false;
  
  long last_update;
  
  Fish(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(0, 0, 0);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);
    
    goal = new Kinematics(0, 0);
    last_update = millis();
  }
  
  // Update pos, vel, or
  public void update() 
  {
    if(pos.x > width) 
    {
      pos.x = canvas_x;
    }
    if(pos.x < canvas_x) 
    {
      pos.x = width;
    }
    if(pos.y > canvas_height) 
    {
      pos.y = canvas_y;
    }
    if(pos.y < canvas_y) 
    {
      pos.y = canvas_height;
    }
    
    Kinematics c = getClosest((Kinematics)this, targets);
    if(inBruceRadius()) 
    {
      avoid(bruce.pos);
    }
    else if(!leader && inRadius(c.pos)) 
    {
      avoid(c.pos);
    } 
    else if(leader || wander) 
    {
      wander();
    } 
    else 
    {
      seek(getClosest((Kinematics)this, new Kinematics[] {targets[0], targets[1]}));
      seek(getClosest((Kinematics)this, targets));
    }
    
    float speed = scale(vel.mag(), maxSpeed);
    vel.normalize();
    vel.mult(speed);
    
    pos.add(vel);
    or = vel.heading();
    last_update = millis();
  }

  public void wander() 
  {
    long dtime = millis() - last_update;
    goal.or += maxRot * (random(1) - random(1)) * dtime * 3;       
    
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
    vel.x = cos(or);
    vel.y = sin(or);
    
    vel.normalize();
    vel.mult(maxSpeed);
  }
  
  public void seek(Kinematics k) 
  {
    PVector tar_pos = k.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    if(inRadius(tar_pos)) 
    {
      goalSpeed = maxSpeed * (distance/radiusOfDecel);
    } 
    else 
    {
      goalSpeed = maxSpeed;
    }
    
    goal.vel = direction;
    goal.vel.normalize();
    goal.vel.mult(goalSpeed);
    linear_acceleration.x = goal.vel.x - vel.x;
    linear_acceleration.y = goal.vel.y - vel.y;
    linear_acceleration.div(timeToTargetVelocity);
    
    vel.add(linear_acceleration);
    vel.normalize();
    vel.mult(goalSpeed);
    
    goal.or = vel.heading();
    
    if(abs(or - goal.or)%(2*PI) < radiusOfSat_rot) 
    {
      or = goal.or;
      return;
    }
       
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
  }
  
  public void avoid(PVector k) 
  {
    PVector tar_pos = k;
    linear_acceleration.x = pos.x - tar_pos.x;
    linear_acceleration.y = pos.y - tar_pos.y;
    linear_acceleration.normalize();
    linear_acceleration.mult(maxAccel);
      
    angular_acceleration = vel.heading();
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    vel.add(linear_acceleration);
  }
  
  public float scale(float a, float b) 
  {
    boolean is_neg = a < 0;
    a = min(abs(a), b);
    if(is_neg) a *= -1;
    return a;
  }
  
  public Kinematics getClosest(Kinematics given, Kinematics[] targetList) 
  {
    Kinematics closest = targetList[0];
    float closest_dist = dist(closest.pos.x, closest.pos.y, given.pos.x, given.pos.y);
    for(int i=0; i < targetList.length; i++) 
    {
      if(given == targetList[i]) 
        continue;
      float d = dist(targetList[i].pos.x, targetList[i].pos.y, given.pos.x, given.pos.y);
      if(d < closest_dist) 
      {
        closest = targetList[i];
        closest_dist = d;
      }
    }
    
    return closest;
  }

  private boolean inRadius(PVector t) 
  {
    return dist(pos.x, pos.y, t.x, t.y) < radiusOfSat;
  }
  
  private boolean inBruceRadius() 
  {
    // 1 dollar for tyler on the random radius
    return dist(pos.x, pos.y, bruce.pos.x, bruce.pos.y) < random(150,100*modifier);
  }
  
  // Draw the fishy on the screen
  public void display() {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 20*modifier, 20*modifier);
    triangle(3*modifier, -10*modifier, 20*modifier, 0, 3*modifier, 10*modifier);
    popMatrix();
  }
}
/**
 * Kinematics.pde
 *
 * @author: Brian Clee
 */

class Kinematics 
{
  PVector pos;
  PVector vel;
  float or;
  float rot;
  int modifier = 1;
  
  Kinematics(int x, int y) 
  {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    or = 0;
    rot = 0;
  }
}
/**
 * Shark.pde
 * 
 * @author: Brian Clee
 */

class Shark extends Kinematics
{
  int c;
  boolean exists;
  float maxSpeed = 2;
  float maxRot = .005f;
  
  float maxAccel = .5f;
  float maxAngularAccel = 0.01f;
  
  float radiusOfSat = 20;
  float radiusOfDecel = 120;
  float radiusOfSat_rot = PI/32;
  float radiusOfDecel_rot = PI/4;
  
  PVector linear_acceleration;
  float angular_acceleration;
  
  float timeToTargetVelocity = 10;
  float timeToTargetRot = 10;
  
  Kinematics goal;
  
  long last_update;
  //long life_time;
  
  Shark(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(155, 0, 0);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);

    goal = new Kinematics(width, PApplet.parseInt(random(500,(height-400))));
    last_update = millis();
    //life_time = millis();
    exists = true;
  }
  
  // Update pos, vel, or
  public boolean update() 
  {
    if(dolphins[0].exists)
    {
      if(pos.x > width || pos.x < canvas_x || pos.y > canvas_height || pos.y < canvas_y) 
      {
        exists = false;
        //life_time = millis();
        return false;
      }
      seekGoal();
      
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
      or = vel.heading();
      last_update = millis();
      return true;
    }
    
    if(pos.x > width) 
    {
      pos.x = canvas_x;
    }
    if(pos.x < canvas_x) 
    {
      pos.x = width;
    }
    if(pos.y > canvas_height) 
    {
      pos.y = canvas_y;
    }
    if(pos.y < canvas_y) 
    {
      pos.y = canvas_height;
    }
    
    wander();
    
    float speed = scale(vel.mag(), maxSpeed);
    vel.normalize();
    vel.mult(speed);
    
    pos.add(vel);
    or = vel.heading();
    last_update = millis();
    
    return true;
  }

  public void wander() 
  {
    long dtime = millis() - last_update;
    goal.or += maxRot * (random(1) - random(1)) * dtime * 3;       
    
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
    vel.x = cos(or);
    vel.y = sin(or);
    
    seekGoal();
    vel.normalize();
    vel.mult(maxSpeed);
  }
  
  public void seekGoal() 
  {
    PVector tar_pos = goal.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    //float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    goalSpeed = maxSpeed;
    
    goal.vel = direction;
    goal.vel.normalize();
    goal.vel.mult(goalSpeed);
    linear_acceleration.x = goal.vel.x - vel.x;
    linear_acceleration.y = goal.vel.y - vel.y;
    linear_acceleration.div(timeToTargetVelocity);
    
    vel.add(linear_acceleration);
    vel.normalize();
    vel.mult(goalSpeed);
    
    goal.or = vel.heading();
    
    if(abs(or - goal.or)%(2*PI) < radiusOfSat_rot) 
    {
      or = goal.or;
      return;
    }
       
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
  }
  
  public float scale(float a, float b) 
  {
    boolean is_neg = a < 0;
    a = min(abs(a), b);
    if(is_neg) a *= -1;
    return a;
  }
  
  public void revive()
  {
    exists = true;
    //life_time = millis();
    pos = new PVector(canvas_x, PApplet.parseInt(random(height)));
    goal = new Kinematics(width, PApplet.parseInt(random(420,height-400)));
  }
  
  public boolean lives()
  {
    return exists;
  }
  
  public void display() 
  {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 40*modifier, 40*modifier); //og: 0, 0, 20, 20
    triangle(6*modifier, -20*modifier, 40*modifier, 0, 6*modifier, 20*modifier); //og: 3, -10, 20, 0, 3, 10
    popMatrix();
  }
}
public static class TimeUtil
{
  public static double systemSeconds()
  {
    return System.nanoTime() / 1000000000.d;
  }  
}  
  public void settings() {  fullScreen(P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "source" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
