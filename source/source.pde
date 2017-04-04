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
PFont font;
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

void setup() 
{
  //start of our world
  worldStart = TimeUtil.systemSeconds();
  elapsed10 = worldStart;
  elapsed60 = worldStart;
  println("width = " + displayWidth);
  println("height = " + displayHeight);
  int numFish = 0;
  canvas_height = displayHeight;
  
  if(displayWidth == 6816 || displayWidth == 3840)
  {
    //immersion theater
    display = "immersion";
    info = loadImage("info_immersion.png");
    modifier = 3;
    //canvas_x = 960;
    canvas_x = 985;
    numFish = 2000;
  }
  else if (displayWidth == 5760)
  {
    //artwall
    display = "artwall";
    info = loadImage("info_artwall.png");
    modifier = 3;
    //canvas_x = 960;
    canvas_x = 985;
    numFish = 1500;
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
  
  font = createFont("Ariel",32,true);
  background(2, 37, 94); //<>//
  fullScreen(P3D);
  //size(1440,900,P3D);
  frameRate(30);
  
  //spawn a shark at a random point on the left side of the screen
  bruce = new Shark(canvas_y, int(random(height)));
  bruce.modifier = modifier;
  
  fishList = new Fish[numFish];
  leaders = new int[fishList.length/100];
  for(int i = 0; i < fishList.length; i++) 
  {
    int x = int(random(canvas_x, width));
    int y = int(random(canvas_y, height));
    fishList[i] = new Fish(x, y);
    fishList[i].targets = fishList;
    fishList[i].maxSpeed = random(1.5) + 2.5;
    //println("color: " + int(pow(fishList[i].maxSpeed, 4)));
    fishList[i].c = color(0, 0, int(random(100,255)));
    fishList[i].modifier = modifier;
  }
  
  for(int i = 0; i < leaders.length; i++)
  {
    int index = int(random(fishList.length));
    fishList[index].leader = true;
    fishList[index].c = color(0, 0, 60);
    fishList[index].maxSpeed = 2;
    leaders[i] = index;
  }
  
  dolphins = new Dolphin[5];
  for(int i = 0; i < dolphins.length; i++)
  {
    dolphins[i] = new Dolphin(canvas_y, int(random(height)));
    dolphins[i].maxSpeed = random(1.5) + 3.5;
    int purp = int(random(130,175));
    dolphins[i].c = color(purp,0,purp);
    dolphins[i].modifier = modifier;
  }
  
  foregroundBubbles = new ArrayList<Bubble>();
  backgroundBubbles = new ArrayList<Bubble>();
}

void draw() 
{
  double currentTime = TimeUtil.systemSeconds();
  elapsed10 = currentTime - elapsed10;
  elapsed60 = currentTime - elapsed60;
  
  boolean ten = false;
  boolean sixty = false;
  //this actually happens every 20 seconds and 120 seconds because im capping at 30 fps... #featurenotabug
  if(elapsed10 > 10.0 && elapsed10 < 100)
  {
    print("10 seconds!");
    ten = true;
    elapsed10 = currentTime;
  }
  if(elapsed60 > 60.0 && elapsed60 < 100)
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
    image(info,0,0); //<>//
  }
  // draws a semi-transparent rectangle over the window to create fading trails
  fill(2, 37, 94, trails);
  rect(0, 0, width, height);
  
  float randomNumber = random(0, 1000);

  //print fps top left
  textFont(font,32);
  fill(255);
  text("FPS: " + frameRate,10,25);

  if(randomNumber > 980) 
  {
    Bubble newBub = new Bubble( color(int(random(100, 255)), 50));
    newBub.modifier = modifier;
    foregroundBubbles.add(newBub);
  }
  else if(randomNumber < 20)   
  {
    Bubble newBub = new Bubble( color(int(random(100, 255)), 50));
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
      PVector goal = new PVector(width, int(random(canvas_y,height)));
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
    bruce.goal.pos = fishList[leaders[int(random(leaders.length))]].pos;
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
      fishList[index].c = color(0, 0, int(random(100,255)));
      fishList[index].maxSpeed = random(1.5) + 2.5;
    }
    
    for(int i = 0; i < leaders.length; i++)
    {
      int index = int(random(fishList.length));
      fishList[index].leader = true;
      fishList[index].c = color(0, 0, 60);
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