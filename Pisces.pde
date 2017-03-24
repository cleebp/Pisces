/**
 * pisces.pde
 * 
 * @author: Brian Clee | bpclee@ncsu.edu
 */
 
Fish[] fishList;
Shark bruce;

Dolphin[] dolphins;

int modifier;
int trails = 69; // original 20, higher = less trail
int[] leaders;

ArrayList<Bubble> foregroundBubbles;
ArrayList<Bubble> backgroundBubbles; 
PImage info;
PFont font;

void setup() 
{
  info = loadImage("info.png");
  font = createFont("Ariel",16,true);
  background(2, 37, 94);
  //fullScreen();
  //modifier = displayWidth / 1000;
  //size(displayWidth, displayHeight);
  size(2880,1950,P3D);//2880,2400 = commons wall
  frameRate(30);
  modifier = 3;
  
  //spawn a shark at a random point on the left side of the screen
  bruce = new Shark(0, int(random(height)));
  bruce.modifier = modifier;
  
  fishList = new Fish[500];
  leaders = new int[fishList.length/100];
  for(int i = 0; i < fishList.length; i++) 
  {
    fishList[i] = new Fish(int(random(width)), int(random(height)));
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
    dolphins[i] = new Dolphin(0, int(random(height)));
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
  image(info,0,0);
  // draws a semi-transparent rectangle over the window to create fading trails
  fill(2, 37, 94, trails);
  rect(0, 400, width, height);
  
  float randomNumber = random(0, 1000);

  //print fps top right
  textFont(font,16);
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
    if (bubble.pos.y < 0)
      backgroundBubbles.remove(i);
    else 
    {
      bubble.update();
      bubble.render();
    }
  }
  
  int m = millis();
  // stupid fucking jank to get around multiple hits on each second
  if(m%1000 < 35)
    m -= m%1000;
  
  // this logic could be cleaned up but you know whatever
  if(bruce.lives() && !dolphins[0].lives())
  {
    if(bruce.longLife())
    {
      PVector goal = new PVector(width, int(random(height)));
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
    if (bruce.longLife())
    {
      bruce.revive();
      bruce.update();
      bruce.display();
    }
  }
  
  
  // every 20 seconds chose a new leader to follow
  if(m%20000 == 0 && !dolphins[0].lives() && bruce.lives())
  {
    bruce.goal.pos = fishList[leaders[int(random(leaders.length))]].pos;
    bruce.update();
    bruce.display();
  }
  
  // every 10 seconds shuffle the leaders
  if(m%10000 == 0)
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