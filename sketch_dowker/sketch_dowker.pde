//int dowker[]={6, 10, 12, 2, 4, 8}; //<>//
//int dowker[]={4,8,14,16,2,18,20,22,10,12,6};
int dowker[]={4, 10, 12, 14, 22, 2, 18, 20, 8, 6, 16};
//int dowker[]={6, 8, 16, 14, 4, 18, 20, 2, 22, 12, 10};
//int dowker[] = {6, 10, 16, 18, 14, 2, 20, 4, 22, 12, 8};
//int dowker[] = {6, 12, 16, 18, 14, 4, 20, 22, 2, 8, 10};
ArrayList<Node> nodes;
ArrayList<Edge>edges;
int outer[];
int outerCount=0;

void setup() {
  size(800, 800);
  nodes = new ArrayList<Node>();
  edges = new ArrayList<Edge>();
  int len = dowker.length;
  for (int i=0; i<len; i++) {
    nodes.add(new Node(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len), 2*i+1, dowker[i], i, 0));// center
    nodes.add(new Node(400+200*cos(PI*2*i/len)+30, 400-200*sin(PI*2*i/len), 2*i+1, dowker[i], i, 1));// right
    nodes.add(new Node(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len)-30, 2*i+1, dowker[i], i, 2));// top
    nodes.add(new Node(400+200*cos(PI*2*i/len)-30, 400-200*sin(PI*2*i/len), 2*i+1, dowker[i], i, 3));// left
    nodes.add(new Node(400+200*cos(PI*2*i/len), 400-200*sin(PI*2*i/len)+30, 2*i+1, dowker[i], i, 4));// bottom
    edges.add(new Edge(5*i, 5*i+1, true)); 
    edges.add(new Edge(5*i, 5*i+2, true)); 
    edges.add(new Edge(5*i, 5*i+3, true)); 
    edges.add(new Edge(5*i, 5*i+4, true)); 
    edges.add(new Edge(5*i+1, 5*i+2, false)); 
    edges.add(new Edge(5*i+2, 5*i+3, false)); 
    edges.add(new Edge(5*i+3, 5*i+4, false)); 
    edges.add(new Edge(5*i+4, 5*i+1, false));
  }
  // a,b は１始まり
  for (int i=0; i<len; i++) {
    for (int j=i+1; j<len; j++) {
      Node n1 = nodes.get(5*i);
      Node n2 = nodes.get(5*j);
      if (n2.b == n1.a-1 || n2.b == n1.a+2*len-1) {
        edges.add(new Edge(5*i+1, 5*j+4, true));
      } else if (n2.b == n1.a+1 ) {
        edges.add(new Edge(5*i+3, 5*j+2, true));
      }
      if (n1.b == n2.a-1 || n1.b == n2.a+2*len-1) {
        edges.add(new Edge(5*i+4, 5*j+1, true));
      } else if (n1.b == n2.a+1 ) {
        edges.add(new Edge(5*i+2, 5*j+3, true));
      }
    }
  }
  outer= new int[20];
  findTriangle();
  modify1();
  modify1();
  // ここで，外周を探しなおす．
  findOuter();
  modify1();
}

float cX = 400, cY = 400, rate=1.0;

float dispX(float x) {
  float xx = x;
  return (xx-cX)*rate + 400;
}
float dispY(float y) {
  float yy = y;
  return (yy-cY)*rate + 400;
}


void draw() {
  background(200);
  for (int e=0; e<edges.size(); e++) {
    Edge ee = edges.get(e);
    if (ee.visible) {
      Node ees = nodes.get(ee.s);
      Node eet = nodes.get(ee.t);
      line (dispX(ees.x), dispY(ees.y), dispX(eet.x), dispY(eet.y));
    }
  }
  for (int n=0; n<nodes.size(); n++) {
    Node nn = nodes.get(n);
    if (n == draggedNodeID) {
      fill(255, 0, 255);
    } else {
      fill(0, 0, 255);
    }
    stroke(0);
    ellipse(dispX(nn.x), dispY(nn.y), 5, 5);
    //text(""+nn.a+","+nn.b, nn.x+10, nn.y+10);
    text(""+n, dispX(nn.x)+10, dispY(nn.y)+10);
  }
}

class Node {
  int a, b;
  float x, y;
  int nodeID;//奇数
  int branchID;// 1: 奇数-1, 2:偶数-1, 3:奇数+1, 4:偶数+1
  Node(float _x, float _y, int _i, int _j, int _nID, int _bID) {
    x=_x;
    y=_y;
    a=_i;
    b=_j;
    nodeID = _nID;
    branchID = _bID;
  }
}

Node getNode( int _nID, int _bID) {
  return nodes.get(_nID*5 + _bID);
}

void debugXY(int k) {
  for (int i=k; i<k+5; i++) {
    println(i, nodes.get(i).x, nodes.get(i).y);
  }
}

class Edge {
  int s, t;
  boolean visible;
  Edge(int _s, int _t, boolean _v) {
    s=_s;
    t=_t;
    visible = _v;
  }
}

int draggedNodeID = -1;
boolean isCenter = false;

void mousePressed() {
  for (int n=0; n<nodes.size(); n++) {
    Node nn = nodes.get(n);
    if (dist(nn.x, nn.y, mouseX, mouseY)<10) {
      if ( n%5==0) {
        isCenter = true;
      } else {
        isCenter = false;
      }
      draggedNodeID = n;
      return ;
    }
  }
}

void mouseDragged() {
  if (draggedNodeID ==-1) {
    return ;
  }
  Node draggedNode = nodes.get(draggedNodeID);
  float dx = mouseX - draggedNode.x;
  float dy = mouseY - draggedNode.y;
  if (isCenter) {
    draggedNode.x = mouseX;
    draggedNode.y = mouseY;
    for (int k = 1; k<=4; k++) {
      draggedNode = nodes.get(draggedNodeID+k);
      draggedNode.x += dx;
      draggedNode.y += dy;
    }
  } else {
    draggedNode.x = mouseX;
    draggedNode.y = mouseY;
  }
}

void mouseReleased() {
  draggedNodeID = -1;
}

void keyPressed() {
  if (key=='n') {
    cX=cY=400;
    rate=1.0;
  } else if (key=='m') {
    cX=((mouseX-400)/rate)+cX;
    cY=((mouseY-400)/rate)+cY;
    rate *=2.0;
  } else {
    modify1();
  }
}

void findTriangle() {
  int nSize = nodes.size();
  outer= new int[nSize];
  for (int a=0; a<nSize; a++) {
    outer[a] = -1;
  }
  int forSize = nSize/5;
  for (int a=0; a<forSize; a++) {
    for (int b=a+1; b<forSize; b++) {
      for (int c=b+1; c<forSize; c++) {
        int eAB_a = -1, eAB_b = -1;
        int eBC_b = -1, eBC_c = -1;
        int eCA_c = -1, eCA_a = -1;
        for (int e=0; e<edges.size(); e++) {
          Edge ee = edges.get(e);
          int s = int(ee.s / 5);
          int t = int(ee.t / 5);
          if (s == a && t == b ) {
            eAB_a = ee.s;
            eAB_b = ee.t;
          } else if (s == b && t == a ) {
            eAB_b = ee.s;
            eAB_a = ee.t;
          } else if (s == b && t == c ) {
            eBC_b = ee.s; 
            eBC_c = ee.t;
          } else if (s == c && t == b ) {
            eBC_c = ee.s; 
            eBC_b = ee.t;
          } else if (s == c && t == a ) {
            eCA_c = ee.s; 
            eCA_a = ee.t;
          } else if (s == a && t == c ) {
            eCA_a = ee.s; 
            eCA_c = ee.t;
          }
        }
        if (eAB_a!=-1 && eBC_b!=-1 && eCA_c!=-1) {
          println("三角形見つけた！");
          println(eAB_a, eAB_b, eBC_b, eBC_c, eCA_c, eCA_a);
          outer[0]=eCA_a;
          outer[1]=eAB_a;
          outer[2]=eAB_b;
          outer[3]=eBC_b;
          outer[4]=eBC_c;
          outer[5]=eCA_c;
          outerCount=6;
          return ;
        }
      }
    }
  }
}

void findOuter() {
  return ;
}

int add1(int a, int nSize) {
  return a%(2*nSize)+1;
}

int findNfromA(int a, int nSize) {
  for (int n=0; n<nSize; n++) {
    if (nodes.get(n).a == a || nodes.get(n).b == a) {
      return n;
    }
  }
  return 0;
}  

void modify1() {
  int len = nodes.size();
  //外周は固定する
  for (int a=0; a<outerCount; a++) {
    nodes.get(outer[a]).x = 400 + 300*cos(PI*2*a/outerCount);
    nodes.get(outer[a]).y = 400 - 300*sin(PI*2*a/outerCount);
  }
  float dx[] = new float [len];
  float dy[] = new float [len];
  for (int repeat=0; repeat<1000; repeat++) {
    for (int n=0; n<len; n++) {
      dx[n] = dy[n] = 0f;
    }
    for (int n=0; n<len; n++) {
      Node nn = nodes.get(n);
      float zx=0;
      float zy=0;
      int count=0;
      for (int e=0; e<edges.size(); e++) {
        Edge ee = edges.get(e);
        if (ee.s == n) {
          zx += nodes.get(ee.t).x;
          zy += nodes.get(ee.t).y;
          count++;
        } else if (ee.t == n) {
          zx += nodes.get(ee.s).x;
          zy += nodes.get(ee.s).y;
          count++;
        }
      }
      zx /= count;
      zy /= count;
      float ax = zx - nn.x;
      float ay = zy - nn.y;
      ax *= 0.1;
      ay *= 0.1;
      dx[n] = ax;
      dy[n] = ay;
    }
    for (int n=0; n<len; n++) {
      boolean OK=true;
      for (int a=0; a<outerCount; a++) {
        if (n==outer[a]) {
          OK=false;
          break;
        }
      }
      if (OK) {
        Node nn = nodes.get(n);
        nn.x += dx[n];
        nn.y += dy[n];
      }
    }
  }
}

//参考文献
//https://www2.cs.arizona.edu/~kpavlou/Tutte_Embedding.pdf
//これはかなりわかりやすい！！