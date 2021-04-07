//-------------------------------------------------------------------
// Line/box clipping
// This code by dan@marginallyclever.com 2021-04-06
// See also https://stackoverflow.com/questions/626812/most-elegant-way-to-clip-a-line
//-------------------------------------------------------------------

class Point2D {
  float x,y;
  
  void set(float xx,float yy) {
    x=xx;
    y=yy;
  }
  
  void set(Point2D p) {
    x=p.x;
    y=p.y;
  }
}

class Particle {
  Point2D p,v;
  
  Particle() {
    p = new Point2D();
    p.x=random(width);
    p.y=random(height);

    float speed = 10;
    v = new Point2D();
    v.x = random(speed*2) - speed;
    v.y = random(speed*2) - speed;
  }
  
  void move(float delta) {
    float x2 = p.x + v.x * delta;
    float y2 = p.y + v.y * delta;

    // bounce off screen edge
    if(x2<0) {
      x2 = -x2;
      v.x = -v.x;
    }
    if(x2>=width) {
      x2 = width-(x2-width);
      v.x = -v.x;
    }
    
    if(y2<0) {
      y2 = -y2;
      v.y = -v.y;
    }
    if(y2>=height) {
      y2 = height-(y2-height);
      v.y = -v.y;
    }
    p.x=x2;
    p.y=y2;
  }
}

class Line {
  Particle a=new Particle();
  Particle b=new Particle();
  
  void draw() {
    line(a.p.x,a.p.y, b.p.x,b.p.y);
  }
  
  void move(float delta) {
    a.move(delta);
    b.move(delta);
  }
}

Line [] lines;

void setup() {
  size(800,800);
  
  // change # of lines here.
  lines = new Line[20];
  for(int i=0;i<lines.length;++i ) {
    lines[i]=new Line();
  }
  /*
  lines[0].a.p.x=50;
  lines[0].a.p.y=10;
  lines[0].b.p.x=50;
  lines[0].b.p.y=50;
  lines[1].a.p.x=50;
  lines[1].a.p.y=40;
  lines[1].b.p.x=50;
  lines[1].b.p.y=90;
  */
}

void draw() {
  background(255);

  // draw rectangle
  int x=width/4;
  int y=height/4;
  stroke(0);
  rect(x,y,width/2,height/2);
  
  // setup rectangle
  Point2D p1=new Point2D();
  Point2D p2=new Point2D();
  Point2D rmax=new Point2D();
  Point2D rmin=new Point2D();
  rmin.set(x,y);
  rmax.set(x+width/2,y+height/2);
  
  for( Line a : lines ) {
    // move line
    a.move(0.3);
    // setup for clipping
    p1.set(a.a.p);
    p2.set(a.b.p);
    // do clip
    if(clipLineToRectangle(p1,p2,rmax,rmin)) {
      // cut part(s)
      stroke(255,0,0);
      line(a.a.p.x,a.a.p.y,p1.x,p1.y);
      line(p2.x,p2.y,a.b.p.x,a.b.p.y);
      // saved part
      stroke(0,255,0);
      line(p1.x,p1.y,p2.x,p2.y);
    } else {
      stroke(255,0,0);
      line(a.a.p.x,a.a.p.y,a.b.p.x,a.b.p.y);
    }
  }
}

/**
 * Clip the line P0-P1 to the rectangle (rMax,rMin).<br>
 * See also https://stackoverflow.com/questions/626812/most-elegant-way-to-clip-a-line
 * @param P0 start of line.
 * @param P1 end of line.
 * @param rMax maximum extent of rectangle
 * @param rMin minimum extent of rectangle
 * @return true if some of the line remains, false if the entire line is cut.
 */
boolean clipLineToRectangle(Point2D P0,Point2D P1,Point2D rMax,Point2D rMin) {
  float xLeft   = rMin.x;
  float xRight  = rMax.x;
  float yBottom = rMin.y;
  float yTop    = rMax.y;
  
  int outCode0, outCode1; 
  
  while(true) {
    outCode0 = outCodes(P0,xLeft,xRight,yTop,yBottom);
    outCode1 = outCodes(P1,xLeft,xRight,yTop,yBottom);
    if( rejectCheck(outCode0,outCode1) ) return false;  // completely out
    if( acceptCheck(outCode0,outCode1) ) return true;  // completely in
    if(outCode0 == 0) {
      break;
    } 
    if( (outCode0 & 1) != 0 ) { 
      P0.x += (P1.x - P0.x)*(yTop    - P0.y)/(P1.y - P0.y);
      P0.y = yTop;
    } else if( (outCode0 & 2) != 0 ) { 
      P0.x += (P1.x - P0.x)*(yBottom - P0.y)/(P1.y - P0.y);
      P0.y = yBottom;
    } else if( (outCode0 & 4) != 0 ) { 
      P0.y += (P1.y - P0.y)*(xRight  - P0.x)/(P1.x - P0.x);
      P0.x = xRight;
    } else if( (outCode0 & 8) != 0 ) { 
      P0.y += (P1.y - P0.y)*(xLeft   - P0.x)/(P1.x - P0.x);
      P0.x = xLeft;
    }
  } 
  while(true) {
    outCode0 = outCodes(P0,xLeft,xRight,yTop,yBottom);
    outCode1 = outCodes(P1,xLeft,xRight,yTop,yBottom);
    if( rejectCheck(outCode0,outCode1) ) return false;  // completely out
    if( acceptCheck(outCode0,outCode1) ) return true;  // completely in
    if(outCode1 == 0) {
      break;
    }
    if( (outCode1 & 1) != 0 ) { 
      P1.x += (P0.x - P1.x)*(yTop    - P1.y)/(P0.y - P1.y);
      P1.y = yTop;
    } else if( (outCode1 & 2) != 0 ) { 
      P1.x += (P0.x - P1.x)*(yBottom - P1.y)/(P0.y - P1.y);
      P1.y = yBottom;
    } else if( (outCode1 & 4) != 0 ) { 
      P1.y += (P0.y - P1.y)*(xRight  - P1.x)/(P0.x - P1.x);
      P1.x = xRight;
    } else if( (outCode1 & 8) != 0 ) { 
      P1.y += (P0.y - P1.y)*(xLeft   - P1.x)/(P0.x - P1.x);
      P1.x = xLeft;
    }
  }
  return true;  // partially in
}


/**
 * Is the point inside the rectangle?
 * @param P
 * @param xLeft
 * @param xRight
 * @param yTop
 * @param yBottom
 * @return 0 for in, bit 1 above, bit 2 below, bit 4 right, bit 8 left.
 */
int outCodes(Point2D P,float xLeft,float xRight,float yTop,float yBottom) {
  int code = 0;
       if(P.y > yTop   ) code += 1; // code for above
  else if(P.y < yBottom) code += 2; // code for below
       if(P.x > xRight ) code += 4; // code for right
  else if(P.x < xLeft  ) code += 8; // code for left
  
  return code;
}
  
  
boolean rejectCheck(int outCode1, int outCode2) {
  return (outCode1 & outCode2) != 0;
} 


boolean acceptCheck(int outCode1, int outCode2) {
  return outCode1==0 && outCode2==0;
}
