import org.openkinect.*;
import org.openkinect.processing.*;
import ddf.minim.*;
import processing.opengl.*;
import proxml.*;
import peasy.*;
import superCAD.*;

//-----------------------------------------
//rec
//**************************************
int maxDepthValue = 1040;  // full range 0-2047, rec'd 530-1040
int minDepthValue = 530;  
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
Kinect kinect;
boolean depth = true;
boolean rgb = false;
boolean ir = false;
boolean process = false;
float deg = 15;  // orig 15
int[] depthArray;
int pixelCounter = 1;
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void setup(){
  setupRecord();
}

void draw(){
  drawRecord();
}


