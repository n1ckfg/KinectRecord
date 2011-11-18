import SimpleOpenNI.*;
import ddf.minim.*;
import processing.opengl.*;
import proxml.*;
import peasy.*;
import superCAD.*;
import javax.swing.JFrame;
import java.awt.*;

JFrame new_window;
MApplet sketchviewer;

void loadNewWindow(){
  if(new_window == null){ // omitting this allows multiple windows
  new_window = new JFrame();
  sketchviewer = new MApplet();
  new_window.getContentPane().add(sketchviewer, BorderLayout.CENTER);
  new_window.setVisible(true);
  sketchviewer.init();
  }
  new_window.setSize(sW, sH);
}

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
String folderIndicator = "_folder";

  int folderCounterOrig=0;
  int filesCounterOrig = 0;
  int playCounterOrig=1;  
  int folderCounter=folderCounterOrig;
  int filesCounter = filesCounterOrig;
  int playCounter=playCounterOrig;
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
boolean firstRun = true;
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
boolean loadedForRec = false;
boolean loadedForRender = false;

//-----------------------------------------

//render
//**************************************
boolean record3D = false; // records 3D rendering or just time-corrects original depth map
int numberOfFolders = 1;  
String readFilePath = "data";
String readFileName = "shot";
String readFileType = "tga"; // record with tga for speed
String writeFilePath = "render";
String writeFileName = "shot";
String writeFileType = "tga";  // render with png to save space
float zscaleMin = 1;
float zscaleMax = 3;
float zscale = zscaleMin; //orig 3
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

PImage img, buffer;

Button[] buttons = new Button[6];

boolean modeRec=false;
boolean modeRender=false;
boolean modePreview=false;
boolean modePlay=false;
boolean needsSaving = false;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void setup() {
  initPlay();
  setupRender();
  //initKinect();
  setupRecord();

  /*
  if(modeRec){
   size(sW,sH,P2D);
   }else if(!modeRec){
   size(sW,sH,OPENGL);
   }
   */
  size(sW, sH,P2D);
  frameRate(fps);

  buttons[0] = new Button(25, height-20, 30, color(240, 10, 10), 12, "rec");
  buttons[1] = new Button(width-25, height-20, 30, color(200, 20, 200), 12, "->3D");
  buttons[2] = new Button(width-60, height-20, 30, color(50, 50, 220), 12, "->2D");
  buttons[3] = new Button(width-95, height-20, 30, color(20, 200, 20), 12, "play");
  buttons[4] = new Button(60, height-20, 30, color(100, 100, 100), 12, "stop");
  buttons[5] = new Button(width/2, height-20, 30, color(200, 200, 50), 12, "cam");
  //buttons[6] = new Button(60, height-20, 30, color(200, 20, 200), 12, "raw");
}

void draw() {
  if((modePreview||modeRec)&&firstRun){
      initKinect();
      firstRun=false;
  }
  if (modePreview) {
    background(0);
    drawCam();
  }
  else {
    background(0);
  }

  if (modeRec) {
    modePreview=true;
    drawRecord();
  }
  
  if(modePlay){
  drawPlay();
  }
  //modeRender moved to separate window
  buttonHandler();
  recDot();
}

void buttonHandler() {
  for (int i=0;i<buttons.length;i++) {
    buttons[i].checkButton();
    buttons[i].drawButton();
  }
}

void mouseReleased() {
  if (buttons[0].clicked) { //REC
    modesRefresh();
    modeRec=true;
    if (!needsSaving) {
      setupRecord();
      needsSaving=true;
    }
  } 
  else if (buttons[1].clicked) { //3D render
    loadNewWindow();
    shotNum = shotNumOrig;
    modesRefresh();
    record3D=true;
    modeRender=true;
  }
  else if (buttons[2].clicked) { //2D render
    loadNewWindow();
    shotNum = shotNumOrig;
    modesRefresh();
    record3D=false;
    modeRender=true;
  }
  else if (buttons[3].clicked) { //PLAY
    modesRefresh();
    initPlay();
    modePlay=true;
  }
  else if (buttons[4].clicked) { //STOP
    modesRefresh();
    if (needsSaving) {
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
  modePlay = false;
  modePreview = false;
  loadedForRec = false;
  loadedForRender = false;
}

void drawCam() {
  if (!firstRun) {
    context.update();
    image(context.depthImage(), -4, 0);
  }
}

void initPlay(){
  folderCounter=folderCounterOrig;
  filesCounter = filesCounterOrig;
  playCounter=playCounterOrig;
  
  File dataFolder = new File(sketchPath, filePath + "/");
  String[] allFiles = dataFolder.list();
  for (int i=0;i<allFiles.length;i++) {
    if (allFiles[i].toLowerCase().endsWith(folderIndicator)) {
      folderCounter++;
    }
  }
  dataFolder = new File(sketchPath, filePath + "/" + fileName + folderCounter + folderIndicator); 
  allFiles = dataFolder.list();
  try{
    for(int j=0;j<allFiles.length;j++){
      if (allFiles[j].toLowerCase().endsWith(fileType)) {
        filesCounter++;
      }
  }
  }catch(Exception e){
  filesCounter=0;
  }
  
  numberOfFolders=folderCounter;
  shotNum = folderCounter;
  shot = folderCounter+1;
  println("folders: " + folderCounter + "   last shot frames: " + filesCounter);
  
}

void drawPlay(){
  try{
String tempPath = filePath + "/" + fileName + folderCounter + folderIndicator+"/" + fileName + folderCounter + "_frame" + playCounter + "." + fileType;
//println(tempPath);  
displayImg=loadImage(tempPath);
image(displayImg,0,0);
if(playCounter<filesCounter){
  playCounter++;
}else{
  playCounter=playCounterOrig;
}
  }catch(Exception e){
    //
  }
}

