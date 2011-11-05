import SimpleOpenNI.*;
import ddf.minim.*;
import processing.opengl.*;
import proxml.*;
import peasy.*;
import superCAD.*;

//-----------------------------------------
//rec
//**************************************
//int maxDepthValue = 1040;  // full range 0-2047, rec'd 530-1040
//int minDepthValue = 530;  
int sW = 640;
int sH = 480;
int fps = 30;

String fileType = "tga";  //tif, tga, jpg, png; use tga for best speed
String audioFileType = "wav";
String fileName = "shot";
String filePath = "data";
//**************************************

//sound
Minim minim;
AudioInput in;
AudioRecorder fout;

//--Kinect sectup
SimpleOpenNI context;
boolean mirror = true;
boolean depthSwitch = true;
boolean rgbSwitch = false;
//--

int fontSize = 12;
boolean record = false;
PImage displayImg;
PFont font;
int counter = 1; 
int shot = 1;
int timestamp;
int timestampInterval = 1000;
String sayText;


XMLInOut xmlIO;
proxml.XMLElement xmlFile;
boolean loaded = false;

//-----------------------------------------

//render
//**************************************
boolean record3D = false; // records 3D rendering or just time-corrects original depth map
int numberOfFolders = 1;  //right now you must set this manually!
String readFilePath = "data";
String readFileName = "shot";
String readFileType = "tga"; // record with tga for speed
String writeFilePath = "render";
String writeFileName = "shot";
String writeFileType = "tga";  // render with png to save space
float zscale = 1; //orig 3
float zskew = 10;
//**************************************

String readString = "";
String writeString = "";
int shotNumOrig = 1;
int shotNum = shotNumOrig;
int readFrameNumOrig = 1;
int readFrameNum = readFrameNumOrig;
int readFrameNumMax;
int writeFrameNum = readFrameNum;
int addFrameCounter = 0;
int subtractFrameCounter = 0;
String xmlFileName = readFilePath + "/" + readFileName + shotNum + ".xml";

PeasyCam cam;
float[][] gray = new float[sH][sW];

File dataFolder;
String[] numFiles; 
int[] timestamps;
int nowTimestamp, lastTimestamp;
float idealInterval = 1000/fps;
float errorAllow = 0;
String diffReport = "";

PImage img,buffer;

Button[] buttons = new Button[6];

boolean modeRec=false;
boolean modeRender=false;
boolean modePreview=true;
boolean needsSaving = false;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void setup(){
  initKinect();
  setupRecord();
  
  /*
  if(modeRec){
  size(sW,sH,P2D);
  }else if(!modeRec){
  size(sW,sH,OPENGL);
  }
  */
  size(sW,sH);
  frameRate(fps);

  buttons[0] = new Button(25, height-20, 30, color(240, 10, 10), 12, "rec");
  buttons[1] = new Button(60, height-20, 30, color(200, 20, 200), 12, "raw");
  buttons[2] = new Button(width-25, height-20, 30, color(50, 50, 220), 12, "save");
  buttons[3] = new Button(width-60, height-20, 30, color(20, 200, 20), 12, "play");
  buttons[4] = new Button(95, height-20, 30, color(100, 100, 100), 12, "stop");
  buttons[5] = new Button(width/2, height-20, 30, color(200, 200, 50), 12, "cam");
}

void draw(){
  if(modePreview){
  background(0);
  drawCam();
  }else{
  background(0);
  }
  
  if(modeRec){
  drawRecord();
  }else if(modeRender){
   drawRender();
  }
  
  buttonHandler();
  recDot();
}

void buttonHandler() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].checkButton();
    buttons[i].drawButton();
  }
}

void mouseReleased(){
  if (buttons[0].clicked) { //REC
  modesRefresh();
  modeRec=true;
  if(!needsSaving){
  needsSaving=true;
  }
  } 
  else if (buttons[1].clicked) { //RAW
  modesRefresh();
  //modeRender=true;
  }
    else if (buttons[2].clicked) { //SAVE
  modesRefresh();
  //modeRender=true;
  }
    else if (buttons[3].clicked) { //PLAY
  modesRefresh();
  //modeRender=true;
  }
    else if (buttons[4].clicked) { //STOP
  modesRefresh();
  if(needsSaving){
      doSaveWrapup();
  }
  }
    else if (buttons[5].clicked) { //CAM
  modesRefresh();
  modePreview = !modePreview;
  }
}

void buttonsRefresh() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].clicked = false;
  }
}

void modesRefresh() {
  buttonsRefresh();
  counter=1;
  modeRec = false;
  modeRender = false;
}

void drawCam(){
  context.update();
  image(context.depthImage(),-4,0);
}


