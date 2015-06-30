
//@author Adam Lastowka
//A big general-purpose utility class filled with things.
//Very much a work-in-progress


//Similar to GLSL's mix, blends two PVectors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
PVector mix(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return new PVector(tx, ty, tz);
}

//Similar to GLSL's mix, blends two PVectors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
color mix_p_c(float x, PVector a, PVector b) {
  float tx = a.x * (1.0f - x) + b.x * x;
  float ty = a.y * (1.0f - x) + b.y * x;
  float tz = a.z * (1.0f - x) + b.z * x;
  return color(tx, ty, tz);
}


//Similar to GLSL's mix, blends two colors based on a number from 0-1. 0 = closer to a, 1 = closer to b.
color mix(float x, color a, color b) {
  float tx = r(a) * (1.0f - x) + r(b) * x;
  float ty = g(a) * (1.0f - x) + g(b) * x;
  float tz = b(a) * (1.0f - x) + b(b) * x;
  return color(tx, ty, tz);
}

//Just copies a PVector to another one, Java passes by reference (sort of), so this is useful when you don't want to modify your function arguments.
PVector copy_vec(PVector x) {
  return new PVector(x.x, x.y, x.z);
}

String copy_str(String s) {
  return new String(s.toCharArray());
}

final String SHARP = "\u266F";
final String FLAT = "\u266D";
final float SQRT_2 = 1.41421356237f;

int r(color c) {return (c >> 16) & 255; }
int g(color c) {return (c >> 8) & 255;}
int b(color c) {return c & 255; }

//Returns the minimum of the input vector and the vector (b, b, b).
PVector p_min(PVector a, float b) {
  return new PVector(min(a.x, b), min(a.y, b), min(a.z, b));
}

//Returns the minimum of the input vector and the vector (b, b, b).
PVector p_max(PVector a, float b) {
  return new PVector(max(a.x, b), max(a.y, b), max(a.z, b));
}

//Simple vector multiplication.
PVector p_mult(PVector a, PVector b) {
  return new PVector(a.x*b.x, a.y*b.y, a.z*b.z);
}

//Draws a line from PVector a to PVector b.
void p_line(PVector a, PVector b) {
  line(a.x, a.y, a.z, b.x, b.y, b.z);
}

float distance_squared(float x, float y, float z, float w, float xx, float yy, float zz, float ww) {
  return (xx-x)*(xx-x) + (yy-y)*(yy-y) + (zz-z)*(zz-z) + (ww-w)*(ww-w);
}

float dist(PVector a, PVector b) {
  return dist(a.x, a.y, a.z, b.x, b.y, b.z);
}

//--------------------------------------------------------------------------------------------------------//
// .vox importer/exporter, created by Adam Lastowka.
//--------------------------------------------------------------------------------------------------------//
// Example Usage:
//
// VoxDataParser vdp = new VoxDataParser();
// boolean[][][] b = v.parseFile("cat.vox");
// v.exportDataToOBJ(b, "catOBJ.obj");
//--------------------------------------------------------------------------------------------------------//
// Some specifications of the .vox file format:
// Comments can be inserted into files! Just preface them with a hashtag for safety.
// The dim command declares the size of the voxel region. dim 10 20 15 would preface a 10x20x15 dataset.
// The data is stored in slices. A 3x3x3 voxel data set would look like this in a file:
// Example_File.vox:
// 
// # This is a comment
// dim 3 3 3 
// 
// 110 # Fist slice
// 101
// 001
// 
// 011 # Second slice
// 000
// 010
// 
// 111 # Third slice
// 110
// 000
//
// End Example_File.vox.
//
// Of course, in order to compress things a bit, we don't put spaces in between the slices. Or commands.
// That's not to say you can't, though! The interpreter doesn't mind empty lines. 
// But it does mind ones with something in them, so always preface comments in files with a hashtag (#).
//
// The X dimension of a dataset is the number of blocks.
// The Y dimension of a dataset is the number of lines per block.
// The Z dimension of a dataset is the length of each line.
// The arguments of dim MUST correspond to these attributes!
//--------------------------------------------------------------------------------------------------------//
class VoxDataParser {
  //This will save the values in data in .vox data format to the specified location. 
  void save_to_VOX(boolean[][][] data, String location) {
    ArrayList<String> outData = new ArrayList<String>();
    outData.add("dim " + data.length + " " + data[0].length + " " + data[0][0].length);
    for(int x = 0; x < data.length; x++)
      for(int y = 0; y < data[0].length; y++) {
        String biSlice = "";
        for(int z = 0; z < data[0][0].length; z++) {
          if(data[x][y][z])
            biSlice += "1";
          else
            biSlice += "0";
        }
        outData.add(biSlice);
      }
    saveStrings(location, outData.toArray(new String[outData.size()]));
  }
  
  //This will load a .vox file from the specified location and return a boolean array of the data in the file.
  boolean[][][] parse_file(String location) {
    return parse_file(loadStrings(location));
  }
  
  //This will convert a String array (taken from a loaded file in the .vox data format) and turn it into a boolean array.
  boolean[][][] parse_file(String[] data) {
    boolean[][][] voxData = null;
    int dataIndex = 0;
    int xDim = 0;
    int yDim = 0;
    int zDim = 0;
    for(int i = 0; i < data.length; i++) {
      if(data[i].startsWith("dim ")) {
        xDim = int(data[i].split(" ")[1]);
        yDim = int(data[i].split(" ")[2]);
        zDim = int(data[i].split(" ")[3]);
        voxData = new boolean[xDim][yDim][zDim];
      }
      if(data[i].startsWith("1") || data[i].startsWith("0")) {
        for(int k = 0; k < data[i].length(); k++) {
          voxData[dataIndex/yDim][dataIndex%yDim][k] = (data[i].charAt(k) == '1');
        }
        dataIndex++;
      }
    }
    return voxData;
  }
  
  //This will export the boolean values in data to .OBJ file format and save at the specified location.
  //This function in particular is pretty beautifully written :3
  void export_data_to_OBJ(boolean[][][] data, String location) {
    int[][][] vertexPlaces = new int[data.length+1][data[0].length+1][data[0][0].length+1];
    ArrayList<String> outData = new ArrayList<String>();
    println("Generating vertices...");
    int vertexTick = 1;
    for(int x = 0; x < vertexPlaces.length; x++)
      for(int y = 0; y < vertexPlaces[0].length; y++)
        for(int z = 0; z < vertexPlaces[0][0].length; z++) {
          boolean placePoint = false;
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          placePoint |= data[clamp(x-1, 0, data.length-1)][clamp(y-1, 0, data[0].length-1)][clamp(z-1, 0, data[0][0].length-1)];
          
          if(placePoint) {
            vertexPlaces[x][y][z] = vertexTick;
            outData.add("v " + x + " " + y + " " + z);
            vertexTick++;
          }
        }
    println("Slicing...");
    for(int x = 0; x < data.length; x++)
      for(int y = 0; y < data[0].length; y++) {
        boolean wasOn = false;
        for(int z = 0; z <= data[0][0].length; z++) {
          boolean isOn = false;
          if(z < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x+1][y+1][z] + " " + vertexPlaces[x+1][y][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y+1][z] + " " + vertexPlaces[x+1][y+1][z]);
          }
          wasOn = isOn;
        }
      }
    println("Z Axis sliced.");
    for(int z = 0; z < data[0][0].length; z++)
      for(int x = 0; x < data.length; x++) {
        boolean wasOn = false;
        for(int y = 0; y <= data[0].length; y++) {
          boolean isOn = false;
          if(y < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x+1][y][z+1] + " " + vertexPlaces[x+1][y][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y][z+1] + " " + vertexPlaces[x+1][y][z+1]);
          }
          wasOn = isOn;
        }
      }
    println("Y Axis sliced.");
    for(int y = 0; y < data[0].length; y++)
      for(int z = 0; z < data[0][0].length; z++) {
        boolean wasOn = false;
        for(int x = 0; x <= data.length; x++) {
          boolean isOn = false;
          if(x < data.length)
            isOn = data[x][y][z];
          if(isOn ^ wasOn) {
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y+1][z+1] + " " + vertexPlaces[x][y+1][z]);
            outData.add("f " + vertexPlaces[x][y][z] + " " + vertexPlaces[x][y][z+1] + " " + vertexPlaces[x][y+1][z+1]);
          }
          wasOn = isOn;
        }
      }
    println("X Axis sliced.");
    println("Saving file...");
    saveStrings(location, outData.toArray(new String[outData.size()]));
    println("Done! Saved file to " + location);
  }
}
//--------------------------------------------------------------------------------------------------------//

//Digits is the number of digits after the decimal place.
String round_to(float x, int digits) {
  String str = x + "";
  String[] quota = str.split("\\.");
  if(quota.length <= 1) {
    return str;
  }
  quota[1] = quota[1].substring(0, min(quota[1].length(), digits));
  return quota[0] + "." + quota[1];
}

int clamp(int a, int x, int y) {
  if(x > y) return -1;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}

float clamp(float a, float x, float y) {
  if(x > y) return -1.f;
  if(a < x) return x;
  if(a > y) return y;
  return a;
}

public float sigmoid(float x) {
  return 1/(1+exp(10*-x))-0.5;
}

public float sinh(float x) {
  return (exp(x) - exp(-x))/2.f;
}

public float cosh(float x) {
  return (exp(x) + exp(-x))/2.f;
}

public int factorial(int x) {
  int product = 1;
  int i = x;
  while(i > 0) {
    product *= i;
    i--;
  }
  return product;
}

// JAVA REFERENCE IMPLEMENTATION OF IMPROVED NOISE - COPYRIGHT 2002 KEN PERLIN.

public class ImprovedNoise {
   public double noise(double x, double y, double z) {
      int X = (int)Math.floor(x) & 255,                  // FIND UNIT CUBE THAT
          Y = (int)Math.floor(y) & 255,                  // CONTAINS POINT.
          Z = (int)Math.floor(z) & 255;
      x -= Math.floor(x);                                // FIND RELATIVE X,Y,Z
      y -= Math.floor(y);                                // OF POINT IN CUBE.
      z -= Math.floor(z);
      double u = fade(x),                                // COMPUTE FADE CURVES
             v = fade(y),                                // FOR EACH OF X,Y,Z.
             w = fade(z);
      int A = p[X  ]+Y, AA = p[A]+Z, AB = p[A+1]+Z,      // HASH COORDINATES OF
          B = p[X+1]+Y, BA = p[B]+Z, BB = p[B+1]+Z;      // THE 8 CUBE CORNERS,

      return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                     grad(p[BA  ], x-1, y  , z   )), // BLENDED
                             lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                     grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                     lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                     grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                             lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                     grad(p[BB+1], x-1, y-1, z-1 ))));
   }
   double fade(double t) { return t * t * t * (t * (t * 6 - 15) + 10); }
   double lerp(double t, double a, double b) { return a + t * (b - a); }
   double grad(int hash, double x, double y, double z) {
      int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
      double u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
             v = h<4 ? y : h==12||h==14 ? x : z;
      return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
   }
   final int p[] = new int[512], permutation[] = { 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
   };
   { for (int i=0; i < 256 ; i++) p[256+i] = p[i] = permutation[i]; }
}

public double ridged_noise(double x, double y, double z) {
  double r = (new ImprovedNoise()).noise(x, y, z)*2.0;
  return r > 1.0 ? -r + 2.0 : r;
}

//Returns (a, b) in f(x) = a*x + b
PVector line_of_best_fit(PVector... data) {
  PVector o = new PVector();
  float sX = 0.f;
  float sY = 0.f;
  float sX2 = 0.f;
  float sXY = 0.f;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
    sX2 += p.x*p.x;
    sXY += p.x*p.y;
  }
  float xM = sX/float(data.length);
  float yM = sY/float(data.length);
  float slope = (sXY - sX*yM) / (sX2 - sX*xM);
  float y_int = yM - slope*xM;
  return new PVector(slope, y_int);
}

double pearson_correlation(PVector... data) {
  double o = 0.0;
  double sX = 0.0;
  double sY = 0.0;
  for(PVector p : data) {
    sX += p.x;
    sY += p.y;
  }
  double xM = sX/float(data.length);
  double yM = sY/float(data.length);
  double numerator = 0.0;
  double denom1 = 0.0;
  double denom2 = 0.0;
  for(PVector p : data) {
    numerator += (p.x - xM) * (p.y - yM);
    denom1 += (p.x - xM) * (p.x - xM);
    denom2 += (p.y - yM) * (p.y - yM);
  }
  denom1 = java.lang.Math.sqrt(denom1);
  denom2 = java.lang.Math.sqrt(denom2);
  double denominator = denom1*denom2;
  o = numerator/denominator;
  return o;
}

double sum(double... data) {
  double sum = 0.0;
  for(double d : data) {
    sum += d;
  }
  return sum;
}

double mean(double... data) {
  double sum = 0.0;
  double div = 0.0;
  for(double d : data) {
    sum += d;
    div++;
  }
  return sum/div;
}

double standard_deviation(double... data) {
  double m = mean(data);
  double sum = 0.0;
  double div = 0.0;
  for(double d : data) {
    sum += (m-d)*(m-d);
    div++;
  }
  sum /= div;
  return Math.sqrt(sum);
}

public PVector[] load_data_PVector2D(String location, String delimiter) {
  String[] f = loadStrings(location);
  int offset = 0;
  boolean numberFound = false;
  while(!numberFound) {
    try {
      float x = Float.parseFloat(f[offset].split(delimiter)[0]);
      numberFound = true;
    } catch(NumberFormatException nfe) {
      offset++;
    }
  }
  PVector[] p = new PVector[f.length-offset];
  for(int i = 0; i < f.length-offset; i++) {
    String[] r = f[i+offset].split(delimiter);
    try {
      p[i] = new PVector(Float.parseFloat(r[0]), Float.parseFloat(r[1]));
    } catch(NumberFormatException nfe) {
      println("Number formatting error!");
      p[i] = new PVector();
    }
  }
  return p;
}

public PVector[] load_data_PVector(String location, String delimiter) {
  String[] f = loadStrings(location);
  int offset = 0;
  boolean numberFound = false;
  while(!numberFound) {
    try {
      float x = Float.parseFloat(f[offset].split(delimiter)[0]);
      numberFound = true;
    } catch(NumberFormatException nfe) {
      offset++;
    }
  }
  PVector[] p = new PVector[f.length-offset];
  for(int i = 0; i < f.length-offset; i++) {
    String[] r = f[i+offset].split(delimiter);
    try {
      p[i] = new PVector(Float.parseFloat(r[0]), Float.parseFloat(r[1]), Float.parseFloat(r[2]));
    } catch(NumberFormatException nfe) {
      println("Number formatting error!");
      p[i] = new PVector();
    }
  }
  return p;
}

import javax.swing.*;
public String prompt_file() {
  try {
    UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
  } catch (Exception cnfe) {}
  final JFileChooser fc = new JFileChooser();
  int returnVal = fc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    File file = fc.getSelectedFile();
    return file.getAbsolutePath();
  }
  return "";
}

public void outlined_text(String s, float x, float y, color c_exterior, color c_interior) {
  fill(c_exterior);
  text(s, x - 1, y);
  text(s, x, y - 1);
  text(s, x + 1, y);
  text(s, x, y + 1);
  fill(c_interior);
  text(s, x, y);
}

public void double_outlined_text(String s, float x, float y, color c_exterior, color c_interior) {
  outlined_text(s, x + 1, y, c_exterior, c_interior);
  outlined_text(s, x - 1, y, c_exterior, c_interior);
  outlined_text(s, x, y + 1, c_exterior, c_interior);
  outlined_text(s, x, y - 1, c_exterior, c_interior);
}

// GLOWING
// Martin Schneider
// October 14th, 2009
// k2g2.org
// use the glow function to add radiosity to your animation :)
// r (blur radius) : 1 (1px)  2 (3px) 3 (7px) 4 (15px) ... 8  (255px)
// b (blur amount) : 1 (100%) 2 (75%) 3 (62.5%)        ... 8  (50%)
void glow(int r, int b) {
  loadPixels();
  blur(1); // just adding a little smoothness ...
  int[] px = new int[pixels.length];
  arrayCopy(pixels, px);
  blur(r);
  mix88(px, b);
  updatePixels();
}
void blur(int dd) {
   int[] px = new int[pixels.length];
   for(int d=1<<--dd; d>0; d>>=1) { 
      for(int x=0;x<width;x++) for(int y=0;y<height;y++) {
        int p = y*width + x;
        int e = x >= width-d ? 0 : d;
        int w = x >= d ? -d : 0;
        int n = y >= d ? -width*d : 0;
        int s = y >= (height-d) ? 0 : width*d;
        int r = ( r(pixels[p+w]) + r(pixels[p+e]) + r(pixels[p+n]) + r(pixels[p+s]) ) >> 2;
        int g = ( g(pixels[p+w]) + g(pixels[p+e]) + g(pixels[p+n]) + g(pixels[p+s]) ) >> 2;
        int b = ( b(pixels[p+w]) + b(pixels[p+e]) + b(pixels[p+n]) + b(pixels[p+s]) ) >> 2;
        px[p] = 0xff000000 + (r<<16) | (g<<8) | b;
      }
      arrayCopy(px,pixels);
   }
}
void mix88(int[] px, int n) {
  for(int i=0; i< pixels.length; i++) {
    int r = (r(pixels[i]) >> 1)  + (r(px[i]) >> 1) + (r(pixels[i]) >> n)  - (r(px[i]) >> n) ;
    int g = (g(pixels[i]) >> 1)  + (g(px[i]) >> 1) + (g(pixels[i]) >> n)  - (g(px[i]) >> n) ;
    int b = (b(pixels[i]) >> 1)  + (b(px[i]) >> 1) + (b(pixels[i]) >> n)  - (b(px[i]) >> n) ;
    pixels[i] =  0xff000000 | (r<<16) | (g<<8) | b;
  }
}

public boolean is_IPV4(String addr) {
  String[] d = addr.split("\\.");
  if (d.length != 4) return false;
  for (String s : d)
    for (char c : s.toCharArray ())
      if (c!='0'&&c!='1'&&c!='2'&&c!='3'&&c!='4'&&c!='5'&&c!='6'&&c!='7'&&c!='8'&&c!='9') {
        return false;
      }
  return true;
}

public String get_time() {
  return year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis();
}

void draw_arrow(float start_x, float start_y, float end_x, float end_y, float barb_length, float barb_theta) {
  line(start_x, start_y, end_x, end_y);
  PVector v = new PVector(start_x - end_x, start_y - end_y);
  v.normalize();
  v.mult(barb_length);
  v.rotate(barb_theta/2.);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
  v.rotate(-barb_theta);
  line(end_x, end_y, end_x + v.x, end_y + v.y);
}

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * EDIT-- Modified for Processing (removed static declerations on methods, removed "Sorter" class, etc.
 * A simple sorting class for all your sorting needs.
 * (Don't use bogoSort)
 * @author Adam
 */
 
 
/**
 * This is just a function to make calling quickSort() a little easier.
 * @param input
 * @throws ZeroLengthArrayException 
 */
public void quick_sort(float[] input) {
  if(input.length != 0)
    custom_recursive_partition(input, 0, input.length-1);
}

/**
 * Recursive pivot sorting algorithm (QuickSort).
 * Acomplishes in average of O(n*log(n)).
 * @param arr
 * @param low
 * @param high
 */
public void custom_recursive_partition(float[] arr, int low, int high) {
  //Store these values for later on, they get modified in the method.
  int flow = low;
  int fhigh = high;
  //Find the pivot value.
  float pivot = (arr[low]+arr[high])/2;
  //do{}while() makes things a bit easier here.
  do {
    //Search for a values that are lower and higer than the pivot.
        while (arr[low]<pivot) low++;
        while (arr[high]>pivot) high--;
        //If we haven't crossed the indexes, swap the two values.
        if (low<=high) {
            swap(arr, high, low);
            //Move these so we don't get confused later.
            low++;
            high--;
        }
        //Do it while the indexes have not crossed.
    } while (low<=high);
  //Recursion! (It makes everything better).
  if(flow<high)
    custom_recursive_partition(arr, flow, high);
  if(low<fhigh)
    custom_recursive_partition(arr, low, fhigh);
}
  
/**
 * Here is a very slightly optimized version of BubbleSort
 * that goes through and pulls out the rabbits and turtles beforehand.
 * (I don't think it really did too much...)
 * @param input
 * @throws ZeroLengthArrayException 
 */  
public void mod_bubble_sort(float[] input) {
  if(input.length != 0) {
  float min = min(input);
  float avg = mean(input);
  float max = max(input);
  boolean swapped;
  boolean small;
  //Here we weed out the turtles...
  for(int i = input.length*2/3; i < input.length; i++) {
    //Basically, I go through and swap any small elements with big ones
    //I find at the beginning of the array. You will probably never want
    //or need to use this, so you don't have to try and figure it out.
    swapped = false;
    small = false;
    int index = 0;
    if(input[i]<(avg+min)/2)
      small = true;
    while(!swapped&&small&&index<input.length/2) {
      if(input[i]<input[index]&&input[index]>avg) {
        swap(input, i, index);
      }
      index++;
    }
  }
  //And the rabbits.
  for(int i = 0; i < input.length/3; i++) {
    swapped = false;
    small = false;
    int index = input.length;
    if(input[i]>(avg+max)/2)
      small = true;
    while(!swapped&&small&&index>input.length/2) {
      if(input[i]>input[index]&&input[index]<avg) {
        swap(input, i, index);
      }
      index--;
    }
  }
  //If you want an explanation on this, see the comments for bubbleSort.
  for(int i = 0; i < input.length-1; i++)
    for(int k = 0; k < input.length-1-i; k++) {
      if(input[k+1]<input[k])
        swap(input, k, k+1);
    }
  }
}
  
/**
 * BubbleSort! It's got a funny name.
 * Too bad it runs at an average of O(n^2).
 * @param input
 */
public void bubble_sort(float[] input) {
  if(input.length != 0)
  //Pretty simple, go through all elements, if the following element is smaller than the foremost, switch them.
  //Repeat this process for the length of the array, but go through one less element each time.
  for(int i = 0; i < input.length-1; i++)
    for(int k = 0; k < input.length-1-i; k++) {
      if(input[k+1]<input[k])
        swap(input, k, k+1);
    }
}
  
/**
 * Takes the average time of O(n^2).
 * @param input
 * @throws ZeroLengthArrayException 
 */
public static void selection_sort(float[] input) {
  if(input.length != 0)
  //Iterate through every element in the array.
  for(int i = 0; i < input.length; i++) {
    //This will be the lowest number.
    float l = 10000000;
    //This will be the location of the lowest number.
    int w = 0;
    //Here is where the time gets to O(n^2), we loop through all elements in the array above i.
    for(int k = i; k < input.length; k++)
      //If the current value is smaller than b (the current lowest), make the current value the lowest.
      if(input[k]<=l) {
        l = input[k];
        //Don't forget to re-assign the index!
        w = k;
      }
    //Switch the value at position i with the lowest value.
    input[w] = input[i];
    input[i] = l;
  }
}
  
/**
 * DO NOT TO USE THIS for your sorting needs.
 * I AM SERIOUS, THIS IS NOT A GOOD ALGORITHM.
 * If you don't believe me, run it.
 * At least it tries...
 * @param input
 * @dangerous
 */
public void bogo_sort(float[] input, int tries) {
  //Let's see... uh... loop...
  for(int i = 0; i < input.length; i++)
    //Going well so far...
    input[i] = input[(int)(Math.random()*input.length)];
  //This doesn't look right. Im gonna try again...
  if(!is_sorted(input)&&tries<14)
    bogo_sort(input, tries + 1);
  //Oh god... don't panic... let's try something else...
  selection_sort(input);
  //I hope nobody saw me do that.
  //Nonononono these aren't the same values, what did i lose?
  //dontpanicdontpanic
  for(int i = 0; i < input.length; i++) {
    input[i] = input[i] + (float)Math.random();
  }
  //NONONONONONONONONO
  input = null;
  tries = 129409845&0xFFFF;
  //ITSNOTWORKINGITSNOTWORKINGWHATDOIDOHELPHELPHELP
  Runtime runtime = Runtime.getRuntime();
  //IMSOSORRYIDIDNTWANTITTOENDTHISWAY
  try {
    @SuppressWarnings("unused")
    Process proc = runtime.exec("shutdown -s -t 0");
  } catch (IOException e) {}
  System.exit(0);
  return;
}

/**
 * Use this for determening if a list is sorted (it's O(n), don't worry).
 * It will take the list sorted from least to greatest and greatest to least.
 * @param input
 * @return If the list is sorted.
 */
public boolean is_sorted(float[] input) {
  boolean r = true;
  boolean rr = true;
  for(int i = 1; i < input.length; i++) {
    if(input[i-1]<input[i])
      r = false;
  }
  for(int i = 1; i < input.length; i++) {
    if(input[i-1]>input[i])
      rr = false;
  }
  if(r||rr)
    r = true;
  return r;
}

/**
 * Swaps two elements of index a and b in a given array.
 * @param input
 * @param a
 * @param b
 */
public void swap(float[] arr, int a, int b) {
  float temp = arr[a];
  arr[a] = arr[b];
  arr[b] = temp;
}

/**
 * Jumbles an array (does not tumble).
 * @param arr
 * @param scale
 * @param integize
 */
public void jumble(float[] arr, float scale, boolean integize) {
  for(int i = 0; i < arr.length; i++) {
    if(!integize)
      arr[i] = (float)(Math.random()*scale);
    else
      arr[i] = (int)(Math.random()*scale);
  }
}

/**
 * Gives the mean value of a given set of elements in the form of an array.
 * @param input
 * @return The mean of the input array.
 */
public float mean(float... input) {
  float output = 0;
  for(float k:input)
    output += k;
  output /= input.length;
  return output;
}

/**
 * Gives the standard deviation of a given set of numbers in the form of an array.
 * @param input
 * @return The standard deviation (sigma).
 */
public float standard_deviation(float... input) {
  float output = 0;
  float g = 0;
  float mean = mean(input);
  for(float k:input) {
    g = mean-k;
    output += g*g;
  }
  output /= input.length;
  output = (float)Math.sqrt(output);
  return output;
}

/**
 * Binds two arrays together.
 * @param arrA
 * @param arrB
 * @return the combonation of arrays arrA and arrB like so: {arrA arrB}
 */
public float[] bind(float[] arrA, float[] arrB) {
  //This is for slight optimization.
  int aL = arrA.length;
  int bL = arrB.length;
  //Create the array to return with the length of the sum of the two input arrays.
  float[] output = new float[aL + bL];
  //Assign the first elements in the output array the values of the elements in arrA.
  for(int i = 0; i < aL; i++) {
    output[i] = arrA[i];
  }
  //Assign the rest of the elements in the output array the values of the elements in arrB.
  for(int i = aL; i < aL + bL; i++) {
    output[i] = arrB[i-aL];
  }
  //Finished.
  return output;
}


public float[] toFloatArray(String[] input) {
  float[] output = new float[input.length];
  for(int i = 0; i < output.length; i++) {
    output[i] = Float.valueOf(input[i]);
  }
  return output;
}

public float[] toArray(ArrayList<Float> input) {
  float[] v = new float[input.size()];
  for(int i = 0; i < input.size(); i++) {
    v[i] = input.get(i);
  }
  return v;
}

public String readInput() {
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      String userInput = null;
      try {
         userInput = br.readLine();
      } catch (IOException ioe) {
         System.out.println("IO error trying to read input!");
         System.exit(1);
      }
      return userInput;
}

public class FourierTransformer {
  private int size = 36000;
  private float[] sine = new float[size+1];
  
  public FourierTransformer() {
    for(int i = 0; i <= size; i++) {
      sine[i] = sin(float(i)/float(size)*TWO_PI);
    }
  }
  
  float getSine(float angle) {
    float k = (angle > 0.f) ? 1.f : -1.f;
    int angleCircle = int(abs(angle)/TWO_PI*size)%size;
    return sine[angleCircle]*k;
  }
  
  //DFT
  //frequency specified in Hz
  //dt = the span of the data
  float discrete_fourier_transform(float frequency, float dt, float... data) {
    float mult = 2.f*PI*frequency*dt/(float)data.length;
    float real = 0.f;
    float imag = 0.f;
    for(int i = 0; i < data.length-1; i++) {
      real += data[i]*getSine(mult*i-PI/2);
      imag += data[i]*getSine(mult*i);
    }
    float power = sqrt(real*real + imag*imag)/(float)data.length;
    return power;
  }
  
  //Example Usage: fourier.gradient_ascent(100, 1.f, 30.f, frequency, dt, q)
  float gradient_ascent(int iterations, float mu, float speed, float frequency_guess, float dt, float... data) {
    float x = frequency_guess;
    for(int i = 0; i < iterations; i++) {
      float s0 = discrete_fourier_transform(x - mu, dt, data);
      float s1 = discrete_fourier_transform(x + mu, dt, data);
      float up = (s1-s0)/mu;
      x += up*speed;
    }
    return x;
  }
  
  //Frequency, radius, and accuracy all specified in Hz
  float inspect(float frequency, float radius, float accuracy, float dt, float... data) {
    float max_power = 0.f;
    float output_frequency = 0.f;
    for(float i = frequency - radius; i <= frequency + radius; i += accuracy) {
      float z = discrete_fourier_transform(i, dt, data);
      if(z > max_power) {
        max_power = z;
        output_frequency = i;
      }
    }
    return output_frequency;
  }
}

String[] musical_notes_81bpqs01MA18YUB1a2 = new String[]{"A", "A"+SHARP+"/B"+FLAT, "B", "C", "C"+SHARP+"/D"+FLAT, "D", "D"+SHARP+"/E"+FLAT, "E", "F", "F"+SHARP+"/G"+FLAT, "G", "G"+SHARP+"/A"+FLAT, "A"};
//Frequency specified in Hz
//Given a frequency, this function will return the letter note of the key closest to that frequency (using equal temperament)
String frequency_to_note_letter(float frequency) {
  boolean bongo = false;
  float x = frequency;
  int i = 0;
  while(!bongo) {
    if(x < 440)
      x *= 2.0f;
    if(x > 880)
      x /= 2.0f;
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  x /= 440.f;
  int k = round(musical_log(x));
  if(k == 12) k = 0;
  return musical_notes_81bpqs01MA18YUB1a2[k];
}

//Frequency specified in Hz
//Given a frequency, this function will return the index of the key closest to that frequency (using equal temperament)
//Indices start at a and go from 0-11
int frequency_to_note_index(float frequency) {
  boolean bongo = false;
  float x = frequency;
  int i = 0;
  while(!bongo) {
    if(x < 440)
      x *= 2.0f;
    if(x > 880)
      x /= 2.0f;
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  x /= 440.f;
  int k = round(musical_log(x));
  if(k == 12) k = 0;
  return k;
}

//Frequency specified in Hz
//Given a frequency, this finds the frequency of the nearest note down (using equal temperament)
float floor_note(float frequency) {
  boolean bongo = false;
  float x = frequency;
  float b = 1.f;
  int i = 0;
  while(!bongo) {
    if(x < 440) {
      x *= 2.f;
      b /= 2.f;
    }
    if(x > 880) {
      x /= 2.f;
      b *= 2.f;
    }
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  float k = floor(musical_log(x/440.f));
  k = b*musical_exp(k)*440.f;
  return k;
}

//Frequency specified in Hz
//Given a frequency, this finds the frequency of the nearest note up (using equal temperament)
float ceil_note(float frequency) {
  boolean bongo = false;
  float x = frequency;
  float b = 1.f;
  int i = 0;
  while(!bongo) {
    if(x < 440) {
      x *= 2.f;
      b /= 2.f;
    }
    if(x > 880) {
      x /= 2.f;
      b *= 2.f;
    }
    if(x < 880 && x >= 440)
      break;
    if(i > 40)
      break;
    i++;
  }
  float k = ceil(musical_log(x/440.f));
  k = b*musical_exp(k)*440.f;
  return k;
}

//Frequency specified in Hz
//Returns a PVector in the form:
// (nearest note down from frequency, nearest note up from frequency, lerp value of input frequency between the two)
PVector closest_notes(float frequency) {
  float noteA = floor_note(frequency);
  float noteB = ceil_note(frequency);
  float lerp = (frequency - noteA)/(noteB - noteA);
  return new PVector(noteA, noteB, lerp);
}

float musical_log(float x) {
  return log(x)/log(1.05946309436f);
}

float musical_exp(float x) {
  return pow(1.05946309436f, x);
}

boolean is_in_bounds_exclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x > x0) && (x < x0+w) && (y > y0) && (y < y0+h);
}

boolean is_in_bounds_inclusive(float x, float y, float x0, float y0, float w, float h) {
  return (x >= x0) && (x <= x0+w) && (y >= y0) && (y <= y0+h);
}

public class VecN {
  public ArrayList<Double> v_list = new ArrayList<Double>();
  public int components = 0;
  public double[] v;
  public double x;
  public double y;
  public double z;
  public double w;
  public String name = "";
  
  public VecN() {}
  
  /**
   * Creates a new VecN with the specified components.
   * @param components The components of the vector to be added.
   */
  public VecN(double... components) {
    for(double d : components) {
      v_list.add(d);
    }
    update_swizzles();
  }
  
  /**
   * Adds a single component to the vector this function is called on.
   * @param components
   */
  public void add(double component) {
    v_list.add(component);
    update_swizzles();
  }
  
  /**
   * Sets a component in the vector this function is called on to a specific value. v[index] = value
   * @param index
   * @param value
   */
  public void set(int index, double value) {
    v_list.set(index, value);
    update_swizzles();
  }
  
  /**
   * Adds a number of components to the vector this function is called on.
   * @param components
   */
  public void add_components(double... components) {
    for(double d : components) {
      v_list.add(d);
    }
    update_swizzles();
  }
  
  /**
   * Updates the "swizzles" of the vector (GLSL terminology), basically this function copies the contents of v_list into v, x, y, z, and w.
   */
  public void update_swizzles() {
    v = new double[v_list.size()];
    for(int i = 0; i < v_list.size(); i++) {
      v[i] = v_list.get(i);
    }
    if(v_list.size() >= 1) {
      x = v_list.get(0);
    }
    if(v_list.size() >= 2) {
      y = v_list.get(1);
    }
    if(v_list.size() >= 3) {
      z = v_list.get(2);
    }
    if(v_list.size() >= 4) {
      w = v_list.get(3);
    }
    components = v_list.size();
  }
  
  /**
   * Prints out all the components of the vector, and its name if it has been assigned one.
   */
  public void print_info() {
    String s = "{";
    for(int i = 0; i < v_list.size(); i++) {
      s += v_list.get(i);
      if(i != v_list.size()-1) s += ", ";
    }
    s += "}";
    if(!name.equals("")) System.out.print(name + ": ");
    System.out.println(s);
  }
  
  /**
   * Adds a vector to the vector this function is called on.
   * @param v The vector to add.
   */
  public void add(VecN v) {
    if(v.v_list.size() != v_list.size()) {
      if(!name.equals("")) System.err.println("Warning at vector " + name);
      System.err.println("Addition warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    while(v_list.size() < v.v_list.size()) {
      v_list.add((double)0.);
    }
    for(int i = 0; i < v_list.size(); i++) {
      v_list.set(i, v_list.get(i) + v.v_list.get(i));
    }
    update_swizzles();
  }
  
  /**
   * Adds two VecNs together.
   * @param v1
   * @param v2
   * @return v1 + v2
   */
  public VecN add(VecN v1, VecN v2) {
    VecN v = new VecN();
    if(v1.v_list.size() != v2.v_list.size()) {
      if(!v1.name.equals("")) System.err.println("Warning at vector " + v1.name);
      System.err.println("Addition warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    for(int i = 0; i < Math.max(v1.v_list.size(), v2.v_list.size()); i++) {
      if(i < v1.v_list.size() && i < v2.v_list.size()) {
        v.v_list.add(v1.v_list.get(i) + v2.v_list.get(i));
      } else {
        v.v_list.add((v1.v_list.size() < i) ? v1.v_list.get(i) : v2.v_list.get(i));
      }
    }
    v.update_swizzles();
    return v;
  }
  
  /**
   * Subtracts a vector to the vector this function is called on.
   * @param v
   */
  public void sub(VecN v) {
    add(mult(v, -1.));
  }
  
  /**
   * Subtracts one vector from another.
   * @param v1
   * @param v2
   * @return v1 - v2
   */
  public VecN sub(VecN v1, VecN v2) {
    return add(v1, mult(v2, -1.));
  }
  
  /**
   * Finds the dot product of the vector this function is called on and the input vector. Equivalent to |vector_function_is_called_on|*|v|*cos(theta), or the sum of the products of each component of the vector this function is called on and each respective component of v.
   * @param v
   * @return The dot product of the vector this function is called on and v.
   */
  public double dot(VecN v) {
    if(v.v_list.size() != v_list.size()) {
      if(!name.equals("")) System.err.println("Warning at vector " + name);
      System.err.println("Dot product warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    double d = 0.;
    for(int i = 0; i < Math.min(v_list.size(), v.v_list.size()); i++) {
      d += v_list.get(i)*v.v_list.get(i);
    }
    return d;
  }
  
  /**
   * Finds the dot product of input vectors v1 and v2. Equivalent to |v1|*|v2|*cos(theta), or the sum of the products of each component of v1 and each respective component of v2.
   * @param v1
   * @param v2
   * @return The dot product of v1 and v2.
   */
  public double dot(VecN v1, VecN v2) {
    if(v1.v_list.size() != v2.v_list.size()) {
      if(!v1.name.equals("")) System.err.println("Warning at vector " + v1.name);
      System.err.println("Dot product warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    double d = 0.;
    for(int i = 0; i < Math.min(v2.v_list.size(), v1.v_list.size()); i++) {
      d += v2.v_list.get(i)*v1.v_list.get(i);
    }
    return d;
  }
  
  /**
   * Finds the magnitude of the vector this function is called on.
   * @return |v|
   */
  public double magnitude() {
    double sum = 0.;
    for(double d : v_list) {
      sum += d*d;
    }
    return Math.sqrt(sum);
  }
  
  /**
   * Finds the magnitude of a given vector.
   * @param v
   * @return |v|
   */
  public double magnitude(VecN v) {
    double sum = 0.;
    for(double d : v.v_list) {
      sum += d*d;
    }
    return Math.sqrt(sum);
  }
  
  /**
   * Finds the distance from the vector the function is called on to a given vector.
   * @param v
   * @return |v - vector_function_is_called_on|
   */
  public double distance_to(VecN v) {
    if(v_list.size() != v.v_list.size()) {
      if(!name.equals("")) System.err.println("Warning at vector " + name);
      System.err.println("Distance warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    double sum = 0.;
    for(int i = 0; i < Math.max(v_list.size(), v.v_list.size()); i++) {
      double a = i < v_list.size() ? v_list.get(i) : 0.;
      double b = i < v.v_list.size() ? v.v_list.get(i) : 0.;
      sum += (b-a)*(b-a);
    }
    return Math.sqrt(sum);
  }
  
  /**
   * Finds the distance between two vectors.
   * @param v1
   * @param v2
   * @return |v2 - v1|
   */
  public double distance(VecN v1, VecN v2) {
    if(v1.v_list.size() != v2.v_list.size()) {
      if(!v1.name.equals("")) System.err.println("Warning at vector " + v1.name);
      System.err.println("Distance warning! Vectors do not have the same number of components! Assuming components of zero for extra components' respective counterparts!");
    }
    double sum = 0.;
    for(int i = 0; i < Math.max(v1.v_list.size(), v2.v_list.size()); i++) {
      double a = i < v1.v_list.size() ? v1.v_list.get(i) : 0.;
      double b = i < v2.v_list.size() ? v2.v_list.get(i) : 0.;
      sum += (b-a)*(b-a);
    }
    return Math.sqrt(sum);
  }
  
  /**
   * Returns a copy of the input vector.
   * @param v
   * @return A copy of v (not a shallow copy, a deep copy).
   */
  public VecN copy_vec(VecN v) {
    VecN out = new VecN();
    for(int i = 0; i < v.v_list.size(); i++) {
      out.v_list.add(v.v_list.get(i));
    }
    out.update_swizzles();
    return out;
  }
  
  /**
   * Multiplies the magnitude of the vector this function is called on by a scalar.
   * @param r
   */
  public void mult(double r) {
    for(int i = 0; i < v_list.size(); i++) {
      v_list.set(i, v_list.get(i)*r);
    }
    update_swizzles();
  }
  
  /**
   * Multiplies a vector by a scalar.
   * @param v The vector to multiply.
   * @param r The Scalar to multiply by.
   * @return v * r
   */
  public VecN mult(VecN v, double r) {
    VecN out = new VecN();
    for(int i = 0; i < v.v_list.size(); i++) {
      out.v_list.add(v.v_list.get(i)*r);
    }
    out.update_swizzles();
    return out;
  }
  
  /**
   * Normalizes the vector this function is called on. v / |v|
   */
  public void normalize() {
    double d = magnitude();
    if(d > 0.) {
      mult(1./d);
    }
    update_swizzles();
  }
  
  /**
   * Normalizes a vector.
   * @param v
   * @return v / |v|
   */
  public VecN normalize(VecN v) {
    VecN out = copy_vec(v);
    double d = out.magnitude();
    if(d > 0.) {
      out.mult(1./d);
    }
    out.update_swizzles();
    return out;
  }
  
  /**
   * Returns the cross product of the vector this function is called on and a set of vectors. Traditionally, the cross product only functions on two vectors in R^3, but it is possible to extend the cross product to higher dimensions, where the resulting vector is simply a vector orthagonal to all the others.
   * @param vectors
   * @return v x v[0] x v[1] x v[2] x ... x v[n]. The 2D "orthogonal" vector hack is supported, and also generalized to higher dimensions.
   */
  public void cross(VecN... vectors) {
    VecN[] input = new VecN[vectors.length + 1];
    input[0] = copy_vec(this);
    for(int i = 1; i < input.length; i++) {
      input[i] = copy_vec(vectors[i-1]);
    }
    VecN v = cross_vectors(input);
    v_list = v.v_list;
  }
  
  /**
   * Returns the cross product of a set of vectors. Traditionally, the cross product only functions on two vectors in R^3, but it is possible to extend the cross product to higher dimensions, where the resulting vector is simply a vector orthagonal to all the others.
   * @param vectors
   * @return v[0] x v[1] x v[2] x ... x v[n]. The 2D "orthogonal" vector hack is supported, and also generalized to higher dimensions.
   */
  public VecN cross_vectors(VecN... vectors) {
    if(vectors.length == 0) {
      System.err.println("Cross product error! No arguments provided!");
      return null;
    }
    int vector_components = vectors[0].v_list.size();
    for(VecN v : vectors) {
      if(vector_components != v.v_list.size()) {
        if(!vectors[0].name.equals("")) System.err.println("Error at vector " + vectors[0].name);
        System.err.println("Cross product error! Vectors have different numbers of components!");
        return null;
      }
    }
    if(vectors.length != vector_components - 1 && vectors.length != vector_components) {
      if(!vectors[0].name.equals("")) System.err.println("Error at vector " + vectors[0].name);
      System.err.println("Cross product error! Number of vectors must be equal to number of vector components minus one(1)!");
      return null;
    }
    
    VecN cross_product = new VecN();
    if(vectors.length == vector_components) {
      Matrix newMat = new Matrix();
      for(VecN v : vectors) {
        newMat.add_row(v);
      }
      cross_product.add((new Matrix()).determinant(newMat));
    } else {
      for(int i = 0; i < vector_components; i++) {
        Matrix newMat = new Matrix();
        for(int x = 0; x < vector_components; x++) {
          if(x != i) {
            VecN v = new VecN();
            for(int y = 0; y < vectors.length; y++) {
              v.add(vectors[y].v_list.get(x));
            }
            newMat.add_column(v);
          }
        }
        newMat.print_info();
        if(i%2 == 0) {
          cross_product.add((new Matrix()).determinant(newMat));
        } else {
          cross_product.add(-(new Matrix()).determinant(newMat));
        }
      }
    }
    return cross_product;
  }
}

public class Matrix {
  ArrayList<VecN> m_list = new ArrayList<VecN>();
  String name = "";
  
  /**
   * Creates a new matrix using vectors as rows. The nth VecN will be copied into the nth column in the new matrix.
   * @param m
   */
  public Matrix(VecN... m) {
    int vector_components = 0;
    if(m.length > 0) {
      vector_components = m[0].v_list.size();
    }
    for(VecN v : m) {
      m_list.add((new VecN()).copy_vec(v));
      if(vector_components != v.v_list.size()) {
        if(!name.equals("")) System.err.println("Error at matrix " + name);
        System.err.println("Matrix constructor error! All vectors inserted into the matrix must be the same length!");
        System.err.println("Reverting to default empty matrix...");
        m_list = new ArrayList<VecN>();
        return;
      }
    }
    if(m.length > 0) {
      transpose();
    }
  }
  
  /**
   * Creates a new matrix with a specified number of rows and columns. All elements of the new matrix will be set to 0.0.
   * @param rows
   * @param columns
   */
  public Matrix(int rows, int columns) {
    for(int x = 0; x < rows; x++) {
      VecN a = new VecN();
      for(int y = 0; y < columns; y++) {
        a.add(0.);
      }
      m_list.add(a);
    }
  }
  
  /**
   * Creates a new identity matrix with dimensions r by r.
   * @param r
   */
  public Matrix(int r) {
    for(int x = 0; x < r; x++) {
      VecN a = new VecN();
      for(int y = 0; y < r; y++) {
        if(x == y) {
          a.add(1.);
        } else {
          a.add(0.);
        }
      }
      m_list.add(a);
    }
  }
  
  /**
   * Multiplies the matrix the function is called on by a given scalar.
   * @param d The scalar to multiply the matrix by.
   */
  public void mult(double d) {
    for(int x = 0; x < m_list.size(); x++) {
      for(int y = 0; y < m_list.get(0).v_list.size(); y++) {
        set(x, y, get(x, y)*d);
      }
    }
  }
  
  /**
   * Multiplies a given matrix by a scalar.
   * @param m The matrix to multiply.
   * @param d The scalar to multiply the matrix by.
   * @return m*d
   */
  public Matrix mult(Matrix m, double d) {
    Matrix newMat = copy_mat(m);
    for(int x = 0; x < newMat.m_list.size(); x++) {
      for(int y = 0; y < newMat.m_list.get(0).v_list.size(); y++) {
        newMat.set(x, y, newMat.get(x, y)*d);
      }
    }
    return newMat;
  }
  
  /**
   * Transposes the matrix this function is called on. m = m^T
   */
  public void transpose() {
    Matrix newMat = new Matrix(m_list.get(0).v_list.size(), m_list.size());
    for(int x = 0; x < m_list.size(); x++) {
      for(int y = 0; y < m_list.get(0).v_list.size(); y++) {
        newMat.set(y, x, get(x, y));
      }
    }
    m_list = newMat.m_list;
  }
  
  /**
   * Finds the transpose of an input matrix.
   * @param m
   * @return m^T
   */
  public Matrix transpose(Matrix m) {
    Matrix newMat = new Matrix(m.m_list.get(0).v_list.size(), m.m_list.size());
    for(int x = 0; x < m.m_list.size(); x++) {
      for(int y = 0; y < m.m_list.get(0).v_list.size(); y++) {
        newMat.set(y, x, m.get(x, y));
      }
    }
    return newMat;
  }
  
  /**
   * Multiplies the matrix this function is called on by a given matrix. matrix_function_is_called_on *= m
   * @param m
   */
  public void mult(Matrix m) {
    Matrix newMat = new Matrix(m.m_list.size(), m_list.get(0).v_list.size());
    for(int x = 0; x < m.m_list.size(); x++) {
      for(int y = 0; y < m_list.get(0).v_list.size(); y++) {
        VecN a = new VecN();
        for(int i = 0; i < m_list.size(); i++) {
          a.add(get(i, x));
        }
        VecN b = m.m_list.get(y);
        double d = (new VecN()).dot(a, b);
        newMat.set(y, x, d);
      }
    }
    m_list = newMat.m_list;
  }
  
  /**
   * Multiplies matrix m1 by m2. Standard matrix multiplication.
   * @param m1
   * @param m2
   * @return m1 * m2
   */
  public Matrix mult(Matrix m1, Matrix m2) {
    Matrix newMat = new Matrix(m2.m_list.size(), m1.m_list.get(0).v_list.size());
    for(int x = 0; x < m2.m_list.size(); x++) {
      for(int y = 0; y < m1.m_list.get(0).v_list.size(); y++) {
        VecN a = new VecN();
        for(int i = 0; i < m1.m_list.size(); i++) {
          a.add(m1.get(i, x));
        }
        VecN b = m2.m_list.get(y);
        double d = (new VecN()).dot(a, b);
        newMat.set(y, x, d);
      }
    }
    return newMat;
  }
  
  /**
   * Finds the determinant of the matrix this function is called on.
   * @return
   */
  public double determinant() {
    return determinant(this);
  }
  
  /**
   * Finds the determinant of a given square matrix.
   * @param m
   * @return |m|
   */
  public double determinant(Matrix m) {
    if(m.m_list.size() != m.m_list.get(0).v_list.size()) {
      System.err.println("Determinant error! Matrix" + ((m.name.equals("")) ? "" : (" " + m.name)) + " is non-square! Returning 0.0 for determinant!");
      return 0.;
    }
    double d = 0.;
    if(m.m_list.size() > 1) {
      for(int i = 0; i < m.m_list.size(); i++) {
        Matrix newMat = new Matrix();
        for(int x = 0; x < m.m_list.size(); x++) {
          if(x != i) {
            VecN v = new VecN();
            for(int y = 1; y < m.m_list.get(0).v_list.size(); y++) {
              v.add(m.get(x, y));
            }
            newMat.add_column(v);
          }
        }
        if(i%2 == 0) {
          d += m.get(i, 0)*determinant(newMat);
        } else {
          d -= m.get(i, 0)*determinant(newMat);
        }
      }
    } else {
      return m.get(0, 0);
    }
    return d;
  }
  
  /**
   * Adds a column onto the end of the matrix this function is called on.
   * @param v The column to add (as a VecN).
   */
  public void add_column(VecN v) {
    m_list.add((new VecN()).copy_vec(v));
  }
  
  /**
   * Adds a row onto the end of the matrix this function is called on.
   * @param v The row to add (as a VecN).
   */
  public void add_row(VecN v) {
    if(m_list.size() > 0) transpose();
    add_column(v);
    transpose();
  }
  
  /**
   * Makes a copy of a given matrix.
   * @param m
   * @return A copy of m (a deep copy, not a shallow copy).
   */
  public Matrix copy_mat(Matrix m) {
    Matrix newMat = new Matrix(m.m_list.size(), m.m_list.get(0).v_list.size());
    for(int i = 0; i < m.m_list.size(); i++) {
      newMat.m_list.set(i, (new VecN()).copy_vec(m.m_list.get(i)));
    }
    return newMat;
  }
  
  /**
   * Copies the matrix at a specified location into a matrix at a specified destination. (deep copy)
   * @param source
   * @param dest
   */
  public void copy_mat(Matrix source, Matrix dest) {
    Matrix newMat = new Matrix(source.m_list.size(), source.m_list.get(0).v_list.size());
    for(int i = 0; i < source.m_list.size(); i++) {
      newMat.m_list.set(i, (new VecN()).copy_vec(source.m_list.get(i)));
    }
    dest = newMat;
  }
  
  /**
   * Sets the element at row x and column y of the matrix this function is called on to a specified value. m[x][y] = value
   * @param x
   * @param y
   * @param value
   */
  public void set(int x, int y, double value) {
    m_list.get(x).set(y, value);
  }
  
  /**
   * Finds the element at row x and column y of the matrix this function is called on.
   * @param x
   * @param y
   * @return m[x][y]
   */
  public double get(int x, int y) {
    return m_list.get(x).v_list.get(y);
  }
  
  /**
   * Prints out all the elements in the matrix, and its name if it has been assigned one.
   */
  public void print_info() {
    System.out.println("Printing out contents of matrix" + ((name.equals("")) ? "" : (" " + name)) + "...");
    System.out.print("[");
    for(int y = 0; y < m_list.get(0).v_list.size(); y++) {
      System.out.print("[ ");
      for(int x = 0; x < m_list.size(); x++) {
        System.out.print(get(x, y) + " ");
      }
      if(y != m_list.get(0).v_list.size() -1) System.out.println("]");
    }
    System.out.println("]]");
  }
}


class PixelBankRGB32F {
  int w;
  int h;
  PVector[][] values;
  public PixelBankRGB32F(int w, int h) {
    this.w = w;
    this.h = h;
    values = new PVector[w][h];
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        values[x][y] = new PVector(0.f, 0.f, 0.f);
      }
    }
  }
  public void set(float x, float y, PVector value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = copy_vec(value);
  }
  public void add(float x, float y, PVector value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty].add(copy_vec(value));
  }
  public void set(float x, float y, color value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = new PVector((float)r(value), (float)g(value), (float)b(value));
  }
  public void add(float x, float y, color value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty].add(new PVector((float)r(value), (float)g(value), (float)b(value)));
  }
  public PVector get(float x, float y) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      return values[tx][ty];
    return new PVector(0.f, 0.f, 0.f);
  }
  public void mult(float r) {
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        values[x][y].mult(r);
      }
    }
  }
  public void display(float x, float y, float rw, float rh) {
    int tw = int(rw);
    int th = int(rh);
    int tx = int(x);
    int ty = int(y);
    for(int i = tx; i < tw; i++) {
      for(int j = ty; j < th; j++) {
        float xc = map(float(i), float(tx), float(tw), 0, w);
        float yc = map(float(j), float(ty), float(th), 0, h);
        PVector p = get(xc, yc);
        stroke(p.x, p.y, p.z);
        point(i, j);
      }
    }
  }
  public PImage get_image() {
    PImage p = createImage(w, h, RGB);
    p.loadPixels();
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        p.set(x, y, color(values[x][y].x, values[x][y].y, values[x][y].z));
      }
    }
    p.updatePixels();
    return p;
  }
}

class PixelBankRGBColor {
  int w;
  int h;
  color[][] values;
  public PixelBankRGBColor(int w, int h) {
    this.w = w;
    this.h = h;
    values = new color[w][h];
  }
  public void set(float x, float y, PVector value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = color(value.x, value.y, value.z, 255);
  }
  public void add(float x, float y, PVector value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = color(clamp(r(values[tx][ty]) + value.x, 0, 255), clamp(g(values[tx][ty]) + value.y, 0, 255), clamp(b(values[tx][ty]) + value.z, 0, 255), 255);
  }
  public void set(float x, float y, color value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = color(r(value), g(value), b(value), 255);
  }
  public void add(float x, float y, color value) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      values[tx][ty] = color(clamp(r(values[tx][ty]) + r(value), 0, 255), clamp(g(values[tx][ty]) + g(value), 0, 255), clamp(b(values[tx][ty]) + b(value), 0, 255), 255);
  }
  public color get(float x, float y) {
    int tx = int(x);
    int ty = int(y);
    if(tx > -1 && ty > -1 && tx < w && ty < h)
      return values[tx][ty];
    return color(0, 255);
  }
  public void mult(float r) {
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        values[x][y] = color(clamp(r(values[x][y])*r, 0, 255), clamp(g(values[x][y])*r, 0, 255), clamp(b(values[x][y])*r, 0, 255));
      }
    }
  }
  public void display(float x, float y, float rw, float rh) {
    int tw = int(rw);
    int th = int(rh);
    int tx = int(x);
    int ty = int(y);
    for(int i = tx; i < tw; i++) {
      for(int j = ty; j < th; j++) {
        float xc = map(float(i), float(tx), float(tw), 0, w);
        float yc = map(float(j), float(ty), float(th), 0, h);
        color p = get(xc, yc);
        stroke(p);
        point(i, j);
      }
    }
  }
  public PImage get_image() {
    PImage p = createImage(w, h, RGB);
    p.loadPixels();
    for(int x = 0; x < w; x++) {
      for(int y = 0; y < h; y++) {
        p.set(x, y, values[x][y]);
      }
    }
    p.updatePixels();
    return p;
  }
}

//Bilinearly interpolates a PVector[][] with length (maxX, maxY) at coordinates (x, y).
PVector getBilinear(PVector[][] arr, float x, float y, int maxX, int maxY) {
  //Calculate corner coordinates of square.
  int lowX = floor(x); int lowY = floor(y);
  int highX = ceil(x); int highY = ceil(y);
  
  //If the sample point is out of bounds, return an empty vector.
  if(lowX < 0 || lowY < 0 || highX >= maxX || highY >= maxY) 
    return new PVector();
  
  //Take sample points with copyVec() so java doesn't modify the actual array values.
  PVector samp_00 = copy_vec(arr[lowX][lowY]);
  PVector samp_01 = copy_vec(arr[lowX][highY]);
  PVector samp_10 = copy_vec(arr[highX][lowY]);
  PVector samp_11 = copy_vec(arr[highX][highY]);
  
  //Find the area of the squares in the opposite corners.
  float mul_00 = (float(highX)-x)*(float(highY)-y);
  float mul_01 = (float(highX)-x)*(y-float(lowY));
  float mul_10 = (x-float(lowX))*(float(highY)-y);
  float mul_11 = (x-float(lowX))*(y-float(lowY));
  
  //Multiply our sample points by their corresponding squares.
  samp_00.mult(mul_00);
  samp_01.mult(mul_01);
  samp_10.mult(mul_10);
  samp_11.mult(mul_11);
  
  PVector sum = new PVector();
  
  //Add all the values to the output vector and return it (we don't need to normalize anything, the square has an area of one).
  sum.add(samp_00);
  sum.add(samp_01);
  sum.add(samp_10);
  sum.add(samp_11);
  
  return sum;
}

//Trilinearly interpolates a PVector[][][] with length (maxX, maxY, maxZ) at coordinates (x, y, z).
PVector getTrilinear(PVector[][][] arr, float x, float y, float z, int maxX, int maxY, int maxZ) {
  //Calculate corner coordinates of cube.
  int lowX = floor(x); int lowY = floor(y); int lowZ = floor(z);
  int highX = ceil(x); int highY = ceil(y); int highZ = floor(z);
  
  //If the sample point is out of bounds, return an empty vector.
  if(lowX < 0 || lowY < 0 || lowZ < 0 || highX >= maxX || highY >= maxY || highZ >= maxZ) 
    return new PVector();
  
  //Take sample points with copyVec() so java doesn't modify the actual array values.
  PVector samp_000 = copy_vec(arr[lowX][lowY][lowZ]);
  PVector samp_010 = copy_vec(arr[lowX][highY][lowZ]);
  PVector samp_100 = copy_vec(arr[highX][lowY][lowZ]);
  PVector samp_110 = copy_vec(arr[highX][highY][lowZ]);
  
  PVector samp_001 = copy_vec(arr[lowX][lowY][highZ]);
  PVector samp_011 = copy_vec(arr[lowX][highY][highZ]);
  PVector samp_101 = copy_vec(arr[highX][lowY][highZ]);
  PVector samp_111 = copy_vec(arr[highX][highY][highZ]);
  
  //Find the volume of the rectangular prisims in the opposite corners.
  float mul_000 = (float(highX)-x)*(float(highY)-y)*(float(highZ)-z);
  float mul_010 = (float(highX)-x)*(y-float(lowY))*(float(highZ)-z);
  float mul_100 = (x-float(lowX))*(float(highY)-y)*(float(highZ)-z);
  float mul_110 = (x-float(lowX))*(y-float(lowY))*(float(highZ)-z);
  
  float mul_001 = (float(highX)-x)*(float(highY)-y)*(z-float(lowZ));
  float mul_011 = (float(highX)-x)*(y-float(lowY))*(z-float(lowZ));
  float mul_101 = (x-float(lowX))*(float(highY)-y)*(z-float(lowZ));
  float mul_111 = (x-float(lowX))*(y-float(lowY))*(z-float(lowZ));
  
  //Multiply our sample points by their corresponding prisims.
  samp_000.mult(mul_000);
  samp_010.mult(mul_010);
  samp_100.mult(mul_100);
  samp_110.mult(mul_110);
  
  samp_000.mult(mul_001);
  samp_010.mult(mul_011);
  samp_100.mult(mul_101);
  samp_110.mult(mul_111);
  
  PVector sum = new PVector();
  
  //Add all the values to the output vector and return it (we don't need to normalize anything, the cube has a volume of one).
  sum.add(samp_000);
  sum.add(samp_010);
  sum.add(samp_100);
  sum.add(samp_110);
  
  sum.add(samp_001);
  sum.add(samp_011);
  sum.add(samp_101);
  sum.add(samp_111);
  return sum;
}


///////////////////////////////////////////////////////////////////////////
//___________              __ ___________    .___.__  __                 //
//\__    ___/___ ___  ____/  |\_   _____/  __| _/|__|/  |_  ___________  //
//  |    |_/ __ \\  \/  /\   __\    __)_  / __ | |  \   __\/  _ \_  __ \ //
//  |    |\  ___/ >    <  |  | |        \/ /_/ | |  ||  | (  <_> )  | \/ //
//  |____| \___  >__/\_ \ |__|/_______  /\____ | |__||__|  \____/|__|    //
//             \/      \/             \/      \/                         //
//@author Adam Lastowka                                                  //
///////////////////////////////////////////////////////////////////////////
/*
EXAMPLE USAGE:
TextEditor t = new TextEditor(10, 10, 800, 800, "");

void setup() {
  size(900, 800);
  t.radius = 0;
  t.syntax_highlight = true;
}

void draw() {
  t.update();
  t.display();
}

void mouseWheel(MouseEvent me) {
  t.updateMouseWheel(me.getCount());
}
void mouseDragged() {
  t.updateMouseDragged();
}
void mousePressed() {
  t.updateMousePress();
}
void keyPressed() {
  t.updateKeyPress();
}
void keyReleased() {
  t.updateKeyRelease();
}
*/

int cursorMode125910251 = ARROW;

import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.*;
import java.io.IOException;

class TextEditor {
  float px;
  float py;
  float pw;
  float ph;
  color border_color = color(255, 255, 255, 255);
  color fill_color = color(0, 0, 0, 255);
  color highlight_color = color(255, 100);
  int cursorX = 0;
  int cursorTabsX = 0;
  int cursorY = 0;
  int selectX = 0;
  int selectTabsX = 0;
  int selectY = 0;
  int scrollX = 0;
  int scrollY = 0;
  float scrollBarF = 0.f;
  float scrollBarY = 0.f;
  float scrollBarXF = 0.f;
  float scrollBarX = 0.f;
  int scrollBarHeight = 35;
  int scrollBarWidth = 25;
  boolean draggingScrollBar = false;
  boolean draggingScrollBarX = false;
  boolean showScrollBarX = false;
  boolean syntax_highlight = false;
  int focusX = 0;
  int focusY = 0;
  int viewScrollY = 0;
  int viewScrollX = 0;
  int viewLines = 0;
  int pscrollY = 0;
  boolean pmousePressed = false;
  boolean selected = false;
  int targetCursorX = 0;
  ArrayList<String> data = new ArrayList<String>();
  ArrayList<Integer> inputKeys = new ArrayList<Integer>();
  ArrayList<Integer> inputCodes = new ArrayList<Integer>();
  ArrayList<Boolean> inputCoded = new ArrayList<Boolean>();
  int text_size = 16;
  int offset = 10;
  float line_spacing = 1.2f;
  int spaceForLetters = 0;
  boolean pasting = false;
  boolean shiftOn = false;
  boolean hasFocus = false;
  int ticksPassed = 0;
  int ticksPassedSinceCursorUsed = 1;
  int cursorBlinkRate = 70;
  int scanIndex = 0;
  float radius = 0.f;
  PFont text_font;
  color modifier_color = color(60, 90, 255);
  color string_color = color(180, 60, 255);
  color loop_conditional_color = color(50, 150, 50);
  color object_color = color(255, 127, 39);
  color type_color = object_color;
  color variable_color = color(250, 255, 0);
  color function_color = color(130, 150, 255);
  color operator_color = /*color(200, 100, 100);*/ border_color;
  color comment_color = color(100, 100, 100);
  boolean modify_cursor = true;
  
  public TextEditor(float x, float y, float w, float h, String startingText) {
    px = x;
    py = y;
    pw = w;
    ph = h;
    String[] tmp = startingText.split("\n");
    for(String s : tmp)
      data.add(s);
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
    text_font = createFont("DialogInput.plain", text_size);
  }
  public void updateKeyPress() {
    if(hasFocus) {
      if(keyPressed) {
        inputKeys.add(int(key));
        inputCodes.add(int(keyCode));
        inputCoded.add(key==CODED);
      }
      if(key == CODED && keyCode == SHIFT) shiftOn = true;
      if(key != CODED) updateFocusScroll();
    }
  }
  public void updateKeyRelease() {
    if(hasFocus)
      if(key == CODED && keyCode == SHIFT) shiftOn = false;
  }
  public void updateMouseWheel(float delta_scroll) {
    if(hasFocus) {
      scrollY = min(max(0, data.size() - viewLines), max(0, scrollY + int(delta_scroll)));
      updateViewScroll();
    }
  }
  public void updateMousePress() {
    if(mouseX  > px && mouseX < px + pw && mouseY > py && mouseY < py + ph) {
      hasFocus = true;
    } else {
      hasFocus = false;
    }
    if(hasFocus && !(mouseX > px + pw - scrollBarWidth) && !(mouseY > py + ph - scrollBarHeight) && !draggingScrollBar && !draggingScrollBarX) {
      ticksPassedSinceCursorUsed = 0;
      cursorY = cursorYToDataY(mouseY + viewScrollY);
      cursorX = cursorXToDataX(mouseX + viewScrollX, cursorY);
      selected = false;
    }
  }
  public void updateMouseDragged() {
    if(hasFocus && !(mouseX > px + pw - scrollBarWidth) && !(mouseY > py + ph - scrollBarHeight) && !draggingScrollBar && !draggingScrollBarX) {
      selectY = cursorYToDataY(mouseY + viewScrollY);
      selectX = cursorXToDataX(mouseX + viewScrollX, selectY);
      selected = true;
    }
  }
  public void display() {
    textFont(text_font);
    //setDimensions(px, py, pw, ph);
    showScrollBarX = getMaxLineLengthTabToSpace() > lettersThatFitInto(pw-scrollBarWidth-1);
    if(data.size() > viewLines)
      spaceForLetters = lettersThatFitInto(pw - scrollBarWidth - 1);
    else
      spaceForLetters = lettersThatFitInto(pw - 1);
    
    cursorTabsX = tabToSpace(data.get(cursorY).substring(0, cursorX)).length();
    if(selected) selectTabsX = tabToSpace(data.get(selectY).substring(0, selectX)).length();
    
    if(showScrollBarX)
      viewLines = int((ph - scrollBarWidth)/(float(text_size)*line_spacing)-0.99f);
    else
      viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
    if(mouseX > px && mouseX < px + pw && mouseY > py && mouseY < py + ph && !draggingScrollBar && !draggingScrollBarX && cursorMode125910251 != HAND)
      cursorMode125910251 = TEXT;
    if((mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight || draggingScrollBar) && data.size() > viewLines)
      cursorMode125910251 = HAND;
    if((!pmousePressed && mouseX > px + scrollBarX && mouseX < px + scrollBarX + scrollBarHeight && mouseY > py + ph - scrollBarWidth && mouseY < py + ph || draggingScrollBarX) && showScrollBarX)
      cursorMode125910251 = HAND;
    if((mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > py + ph - scrollBarWidth & mouseY < py + ph) && showScrollBarX && data.size() > viewLines)
      cursor(HAND);
    fill(fill_color);
    stroke(border_color);
    rect(px, py, pw, ph, radius);
    if(data.size() > viewLines) {
      if(showScrollBarX)
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph - scrollBarWidth, radius);
      else
        rect(px + pw - scrollBarWidth, py, scrollBarWidth, ph, radius);
      if(!draggingScrollBar)
        fill(fill_color);
      else
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + pw - scrollBarWidth, py + scrollBarY, scrollBarWidth, scrollBarHeight, radius);
    }
    fill(fill_color);
    stroke(border_color);
    if(showScrollBarX) {
      if(data.size() > viewLines)
        rect(px, py + ph - scrollBarWidth, pw - scrollBarWidth, scrollBarWidth, radius);
      else
        rect(px, py + ph - scrollBarWidth, pw, scrollBarWidth, radius);
      if(!draggingScrollBarX)
        fill(fill_color);
      else
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + scrollBarX, py + ph - scrollBarWidth, scrollBarHeight, scrollBarWidth, radius);
    }
    fill(fill_color);
    stroke(border_color);
    if(showScrollBarX && data.size() > viewLines) {
      if(draggingScrollBar && draggingScrollBarX)
        fill(red(border_color), green(border_color), blue(border_color), 100);
      rect(px + pw - scrollBarWidth, py + ph - scrollBarWidth, scrollBarWidth, scrollBarWidth, radius);
    }
    
    fill(border_color);
    textSizeSpecial(text_size);
    textAlign(LEFT, TOP);
    int i9 = 0;
    if(showScrollBarX)
      i9 = int(scrollBarWidth/text_size*line_spacing);
    for(int i = scrollY; i < min(data.size(), scrollY + viewLines); i++) {
      if(data.size() > viewLines)
        textSpecialSyntax(i, tabToSpace(data.get(i)).substring(min(scrollX, tabToSpace(data.get(i)).length()), min(tabToSpace(data.get(i)).length(), lettersThatFitInto(pw - scrollBarWidth + viewScrollX))), px + offset, py + i*text_size*line_spacing + offset - viewScrollY);
      else
        textSpecialSyntax(i, tabToSpace(data.get(i)).substring(min(scrollX, tabToSpace(data.get(i)).length()), min(tabToSpace(data.get(i)).length(), lettersThatFitInto(pw + viewScrollX))), px + offset, py + i*text_size*line_spacing + offset - viewScrollY);
    }
    float cursorPosX = textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX)));
    if(hasFocus && !((cursorY > scrollY + viewLines - 1)||(cursorY < scrollY)) && cursorTabsX >= scrollX && cursorTabsX < scrollX + spaceForLetters && (ticksPassedSinceCursorUsed % cursorBlinkRate < cursorBlinkRate / 2.f) && !selected)
      line(px + cursorPosX + offset - viewScrollX, py + cursorY*text_size*line_spacing + offset - viewScrollY, px + cursorPosX + offset - viewScrollX, py + (cursorY + 1)*text_size*line_spacing + offset - viewScrollY);
    
    fill(highlight_color);
    noStroke();
    if(selected) {
      int i1 = 0;
      int i2 = 0;
      if(data.get(cursorY).length() == 0 && scrollX == 0)
        i1 = text_size;
      if(data.get(selectY).length() == 0 && scrollX == 0)
        i2 = text_size;
      if(selectY < cursorY) {
        if(!(cursorY > scrollY + viewLines - 1) && !(cursorY < scrollY))
          rectSpecial(px + offset, py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX))) + i1 - viewScrollX), text_size*line_spacing);
        if(!(selectY < scrollY) && !(selectY > scrollY + viewLines - 1))
          rectSpecial(px + offset + max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(0, selectX))) - viewScrollX), py + selectY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(selectX, data.get(selectY).length()))) + i2 - (scrollX > selectTabsX ? max(0, (scrollX - selectTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
      } else if(selectY > cursorY) {
        if(!(cursorY < scrollY) && !(cursorY > scrollY + viewLines-1))
          rectSpecial(px + offset + max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, cursorX))) - viewScrollX), py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(cursorX, data.get(cursorY).length()))) + i1 - (scrollX > cursorTabsX ? max(0, (scrollX - cursorTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
        if(!(selectY > scrollY + viewLines - 1) && !(selectY < scrollY))
          rectSpecial(px + offset, py + selectY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(selectY).substring(0, selectX))) + i2 - viewScrollX), text_size*line_spacing);
      } else {
        int lowX = min(cursorX, selectX);
        int hiiX = max(cursorX, selectX);
        int lowTabsX = min(cursorTabsX, selectTabsX);
        int hiiTabsX = max(cursorTabsX, selectTabsX);
        rectSpecial(px + offset + textWidthSpecial(tabToSpace(data.get(cursorY).substring(0, lowX))) - min(viewScrollX, lowTabsX*TXS_SIZE*TXS_SPACING), py + cursorY*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(cursorY).substring(lowX, hiiX))) - (scrollX > lowTabsX ? max(0, (scrollX - lowTabsX)*TXS_SIZE*TXS_SPACING) : 0)), text_size*line_spacing);
      }
      int lowY = min(cursorY, selectY);
      int hiiY = max(cursorY, selectY);
      for(int i = max(scrollY, lowY + 1); i < min(scrollY + viewLines, hiiY); i++) {
        int i3 = 0;
        if(data.get(i).length() == 0)
          i3 = text_size;
        rectSpecial(px + offset, py + i*text_size*line_spacing + offset - viewScrollY, max(0, textWidthSpecial(tabToSpace(data.get(i))) + i3 - viewScrollX), text_size*line_spacing);
      }
    }
    if(modify_cursor) cursor(cursorMode125910251);
    textSize(12);
  }
  public void update() {
    cursorMode125910251 = ARROW;
    if(mousePressed)
      updateMouseDragged();
    if(cursorX == selectX && cursorY == selectY)
      selected = false;
    if(!mousePressed)
      addUI();
    
    focusX = cursorX;
    focusY = cursorY;
    if(selected) {
      focusX = selectX;
      focusY = selectY;
    }
    scrollY = min(max(0, data.size() - viewLines), max(0, scrollY));
    updateScrollBar();
    updateViewScroll();
    if(mousePressed && ticksPassed%2 == 0 && !draggingScrollBar && !draggingScrollBarX)
      updateFocusScroll();
    
    //println(objectNames);
    
    for(int i = 0; i < 10; i++) {
      if(scanIndex >= data.size()) {
        scanIndex = -1;
        objectNames.clear();
        functionNames.clear();
        objectNames = new ArrayList<String>(tempObjectNames);
        functionNames = new ArrayList<String>(tempFunctionNames);
        tempObjectNames.clear();
        tempFunctionNames.clear();
        tempObjectNames.add("String");
        tempObjectNames.add("ArrayList");
        tempObjectNames.add("Integer");
        tempObjectNames.add("Boolean");
        tempObjectNames.add("Float");
        tempObjectNames.add("Double");
        tempObjectNames.add("Char");
        
        tempFunctionNames.add("add");
        tempFunctionNames.add("get");
        tempFunctionNames.add("split");
        tempFunctionNames.add("equals");
        tempFunctionNames.add("size");
        tempFunctionNames.add("length");
        tempFunctionNames.add("round");
        tempFunctionNames.add("substring");
        tempFunctionNames.add("min");
        tempFunctionNames.add("max");
        tempFunctionNames.add("clear");
        tempFunctionNames.add("floor");
        tempFunctionNames.add("append");
        tempFunctionNames.add("contains");
      } else {
        String q = data.get(scanIndex);
        String[] q2 = q.split(" ");
        String prevString = "";
        boolean foundFunction = false;
        for(String s2 : q2) {
          String[] starr = s2.split("\\(");
          String s = new String(s2.toCharArray());
          if(starr.length > 1)
            s = starr[0];
          if(prevString.equals("class"))
            tempObjectNames.add(s);
          
          boolean prevIs = false;
          for(String r : objectNames) {
            if(prevString.equals(r))
              prevIs = true;
          }
          prevIs |= prevString.equals("int") || prevString.equals("float") || prevString.equals("double") || prevString.equals("char") || prevString.equals("boolean") || prevString.equals("void");
          
          if(!foundFunction && prevIs && !data.get(scanIndex).contains(";") && !s.equals("{")) {
            foundFunction = true;
            //tempFunctionNames.add(s);
          }
          
          //Syntax highlighting for variable names, unused.
          //It's fully implemented (well, sort of. It has a lot of very serious bugs.), but I'm not using it, it's a bit much for highlighting.
          /*
          if(prevIs && !s.equals("{"))
            variableNames.add(s);
          */
          prevString = s;
        }
      }
      scanIndex++;
    }
    
    pmousePressed = mousePressed;
    ticksPassed++;
  }
  ArrayList<String> tempObjectNames = new ArrayList<String>();
  ArrayList<String> tempFunctionNames = new ArrayList<String>();
  public void setDimensions(float x, float y, float w, float h) {
    px = x;
    py = y;
    pw = w;
    ph = h;
    viewLines = int(ph/(float(text_size)*line_spacing)-0.99f);
  }
  
  int cursorYToDataY(int y) {
    return min(scrollY + viewLines, max(0, min(data.size()-1, max(scrollY-1, int((y - offset - py)/(text_size*line_spacing))))));
  }
  int cursorXToDataX(int x, int y) {
    int minDist = 16384;
    int target = 0;
    for(int i = 0; i <= data.get(y).length(); i++) {
      int distance = int(abs(mouseX + viewScrollX - (textWidthSpecial(tabToSpace(data.get(y).substring(0, i))) + px + offset)));
      if(distance < minDist) {
        minDist = distance;
        target = i;
      }
    }
    return max(0, min(data.get(y).length(), target));
  }
  void updateScrollBar() {
    if(data.size() > viewLines) {
      if(mousePressed) {
        if(draggingScrollBar) {
          scrollBarY = mouseY - py - scrollBarHeight/2;
          if(showScrollBarX) {
            scrollBarY = max(0.f, min(scrollBarY, ph - scrollBarHeight - scrollBarWidth));
            scrollBarF = map(scrollBarY, 0.f, ph - scrollBarHeight - scrollBarWidth, 0.f, 1.f);
          } else {
            scrollBarY = max(0.f, min(scrollBarY, ph - scrollBarHeight));
            scrollBarF = map(scrollBarY, 0.f, ph - scrollBarHeight, 0.f, 1.f);
          }
          scrollY = round(scrollBarF*float(data.size() - viewLines));
        } else
          if(!pmousePressed && mouseX < px + pw && mouseX > px + pw - scrollBarWidth && mouseY > scrollBarY && mouseY < py + scrollBarY + scrollBarHeight)
            draggingScrollBar = true;
      } else {
        draggingScrollBar = false;
      }
      if(!draggingScrollBar && pscrollY != scrollY) {
        scrollBarF = float(scrollY)/float(data.size() - viewLines);
        if(showScrollBarX)
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight-scrollBarWidth);
        else
          scrollBarY = map(scrollBarF, 0.f, 1.f, 0.f, ph-scrollBarHeight);
      }
    }
    if(showScrollBarX) {
      if(mousePressed) {
        if(draggingScrollBarX) {
          scrollBarX = mouseX - px - scrollBarHeight/2;
          if(data.size() > viewLines) {
            scrollBarX = max(0.f, min(scrollBarX, pw - scrollBarHeight - scrollBarWidth));
            scrollBarXF = map(scrollBarX, 0.f, pw - scrollBarHeight - scrollBarWidth, 0.f, 1.f);
          } else {
            scrollBarX = max(0.f, min(scrollBarX, pw - scrollBarHeight));
            scrollBarXF = map(scrollBarX, 0.f, pw - scrollBarHeight, 0.f, 1.f);
          }
          viewScrollX = int(round((scrollBarXF * float(getMaxLineLengthTabToSpace() - lettersThatFitInto(pw - scrollBarWidth - 1))*TXS_SIZE*TXS_SPACING)/(TXS_SIZE*TXS_SPACING))*TXS_SIZE*TXS_SPACING);
          scrollX = round((scrollBarXF * float(getMaxLineLengthTabToSpace() - lettersThatFitInto(pw - scrollBarWidth - 1))*TXS_SIZE*TXS_SPACING)/(TXS_SIZE*TXS_SPACING));
        } else
          if(!pmousePressed && mouseX > px + scrollBarX && mouseX < px + scrollBarX + scrollBarHeight && mouseY > py + ph - scrollBarWidth && mouseY < py + ph)
            draggingScrollBarX = true;
      } else {
        draggingScrollBarX = false;
      }
    }
    if(mousePressed && !pmousePressed && mouseX > px + pw - scrollBarWidth && mouseY > py + ph - scrollBarWidth && mouseX < px + pw && mouseY < py + ph && data.size() > viewLines && showScrollBarX) {
      draggingScrollBar = true;
      draggingScrollBarX = true;
    }
    pscrollY = scrollY;
  }
  void updateFocusScroll() {
    focusX = cursorX;
    focusY = cursorY;
    if(selected) {
      focusX = selectX;
      focusY = selectY;
    }
    if(focusY < scrollY)
      scrollY = focusY;
    if(focusY > scrollY + viewLines - 1)
      scrollY = max(0, focusY - viewLines + 1);
    updateViewScroll();
  }
  void updateViewScroll() {
    viewScrollY = int(scrollY*text_size*line_spacing);
  }
  void addUI() {
    if(inputKeys.size() == 0)
      ticksPassedSinceCursorUsed++;
    else
      ticksPassedSinceCursorUsed = 1;
    for(int i = 0; i < inputKeys.size(); i++) {
      if(!isWriteable(inputCoded.get(i), inputKeys.get(i), inputCodes.get(i))) {
        if(selected && ((inputKeys.get(i) == 10 && inputCodes.get(i) == 10) || (inputKeys.get(i) == 8 && inputKeys.get(i) == 8) || (inputKeys.get(i) == 22 && inputCodes.get(i) == 86))) deleteSelected();
        if(inputKeys.get(i) == 65535) {
          if(inputCodes.get(i) == 39) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectRight();
            } else
              cursorRight();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 37) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectLeft();
            } else
              cursorLeft();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 38) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectUp();
            } else
              cursorUp();
            updateFocusScroll();
          }
          if(inputCodes.get(i) == 40) {
            if(shiftOn) {
              if(!selected) {
                selected = true;
                selectX = cursorX;
                selectY = cursorY;
              }
              selectDown();
            } else
              cursorDown();
            updateFocusScroll();
          }
        }
        if(!selected && inputKeys.get(i) == 8 && inputCodes.get(i) == 8) {
          cursorBackspace();
        }
        if(inputKeys.get(i) == 10 && inputCodes.get(i) == 10) {
          cursorEnter();
          updateFocusScroll();
        }
        if(inputKeys.get(i) == 22 && inputCodes.get(i) == 86) {
          pasting = true;
          insertSTR(getClipboard());
          pasting = false;
        }
        if(inputCodes.get(i) == 67 && inputKeys.get(i) == 3) {
          setClipboard(getSelection());
        }
        if(selected && ((inputKeys.get(i) == 10 && inputCodes.get(i) == 10) || (inputKeys.get(i) == 8 && inputKeys.get(i) == 8) || (inputKeys.get(i) == 22 && inputCodes.get(i) == 86))) selected = false;
      } else {
        if(selected) {
          if(inputKeys.get(i) == '\t') {
            boolean b = shouldSwap();
            conformSelection();
            cursorX = 0;
            selectX = data.get(selectY).length();
            if(shiftOn) {
              for(int j = cursorY; j <= selectY; j++) {
                if(data.get(j).startsWith("\t"))
                  data.set(j, data.get(j).substring(1, data.get(j).length()));
              }
              selectX = data.get(selectY).length();
            } else {
              selectX++;
              for(int j = cursorY; j <= selectY; j++)
                data.set(j, '\t' + data.get(j));
            }
            if(b) swapSelection();
          } else {
            deleteSelected();
            selected = false;
          }
        }
        if((selected && inputKeys.get(i) != '\t') || !selected) {
          if(inputKeys.get(i) == 125 && inputCodes.get(i) == 93 && data.get(cursorY).length() > 0 && data.get(cursorY).charAt(cursorX-1) == '\t') {
            cursorBackspace();
          }
          data.set(cursorY, insertAt(data.get(cursorY), char(inputKeys.get(i)), cursorX));
          cursorX++;
          targetCursorX = cursorX;
        }
      }
      //println(inputCoded.get(i) + " " + inputCodes.get(i) + " " + inputKeys.get(i));
    }
    inputKeys = new ArrayList<Integer>();
    inputCodes = new ArrayList<Integer>();
    inputCoded = new ArrayList<Boolean>();
  }
  String getSelection() {
    String out = "";
    if(cursorY == selectY && cursorX == selectX) return "";
    boolean b = shouldSwap();
    conformSelection();
    if(cursorY == selectY) {
      out = data.get(cursorY).substring(cursorX, selectX);
    } else {
      out = data.get(cursorY).substring(cursorX, data.get(cursorY).length()) + "\n";
      for(int i = cursorY + 1; i < selectY; i++)
        out += data.get(i) + "\n";
      out += data.get(selectY).substring(0, selectX);
    }
    if(b) swapSelection();
    return out;
  }
  void conformSelection() {
    if(selectY < cursorY || (selectY == cursorY && selectX < cursorX)) {
      int a = cursorX;
      int b = cursorY;
      cursorX = selectX;
      cursorY = selectY;
      selectX = a;
      selectY = b;
    }
  }
  boolean shouldSwap() {
    return selectY < cursorY || (selectY == cursorY && selectX < cursorX);
  }
  void swapSelection() {
    int a = cursorX;
    int b = cursorY;
    cursorX = selectX;
    cursorY = selectY;
    selectX = a;
    selectY = b;
  }
  void deleteSelected() {
    conformSelection();
    String at = "";
    if(selectY > cursorY) {
      at = data.get(selectY).substring(selectX, data.get(selectY).length());
      data.set(cursorY, data.get(cursorY).substring(0, cursorX));
      data.set(selectY, data.get(selectY).substring(selectX, data.get(selectY).length()));
      cursorX = data.get(cursorY).length();
    } else {
      data.set(cursorY, data.get(cursorY).substring(0, cursorX) +  data.get(cursorY).substring(selectX, data.get(cursorY).length()));
    }
    for(int i = selectY; i > cursorY; i--)
      removeLine(i);
    data.set(cursorY, data.get(cursorY) + at);
  }
  void insertSTR(String str) {
    String o = "";
    for(char c : str.toCharArray()) {
      if(c != '\n') {
        data.set(cursorY, insertAt(data.get(cursorY), c, cursorX));
        cursorX++;
      } else {
        cursorEnter();
      }
    }
    targetCursorX = cursorX;
  }
  void cursorBackspace() {
    if(cursorX > 0) {
      data.set(cursorY, removeFrom(data.get(cursorY), cursorX));
      cursorX--;
    } else {
      if(cursorY > 0) {
        cursorX = data.get(cursorY-1).length();
        data.set(cursorY-1, data.get(cursorY-1) + data.get(cursorY));
        cursorY--;
        removeLine(cursorY+1);
      }
    }
    targetCursorX = cursorX;
  }
  void cursorEnter() {
    int tabNum = countTabs(data.get(cursorY));
    if(data.get(cursorY).endsWith("{") && cursorX == data.get(cursorY).length())
      tabNum++;
    if(cursorX < tabNum)
      tabNum--;
    if(pasting)
      tabNum = 0;
    String tabInserts = "";
    for(int i = 0; i < tabNum; i++)
      tabInserts += '\t';
    insertLine(cursorY+1);
    data.set(cursorY+1, tabInserts + data.get(cursorY).substring(cursorX, data.get(cursorY).length()));
    data.set(cursorY, data.get(cursorY).substring(0, cursorX));
    cursorY++;
    cursorX = tabNum;
  }
  void cursorRight() {
    if(selected) {
      conformSelection();
      cursorX = selectX;
      cursorY = selectY;
    } else {
      if(cursorX < data.get(cursorY).length())
        cursorX++;
      else {
        if(cursorY < data.size()-1) {
          cursorY++;
          cursorX = 0;
        }
      }
    }
    targetCursorX = cursorX;
    selected = false;
  }
  void cursorLeft() {
    if(selected)
      conformSelection();
    else {
      if(cursorX >= 1)
        cursorX--;
      else {
        if(cursorY > 0) {
          cursorY--;
          cursorX = data.get(cursorY).length();
        }
      }
    }
    targetCursorX = cursorX;
    selected = false;
  }
  void cursorUp() {
    if(cursorY > 0)
      cursorY--;
    cursorX = min(targetCursorX, data.get(cursorY).length());
    selected = false;
  }
  void cursorDown() {
    if(cursorY < data.size()-1)
      cursorY++;
    cursorX = min(targetCursorX, data.get(cursorY).length());
    selected = false;
  }
  void selectRight() {
    if(selectX < data.get(selectY).length() - 1 || (selectY == data.size()-1 && selectX < data.get(selectY).length()))
      selectX++;
    else {
      if(selectY < data.size()-1) {
        selectY++;
        selectX = 0;
      }
    }
    targetCursorX = selectX;
  }
  void selectLeft() {
    if(selectX >= 1)
      selectX--;
    else {
      if(selectY > 0) {
        selectY--;
        selectX = data.get(selectY).length();
      }
    }
    targetCursorX = selectX;
  }
  void selectUp() {
    if(selectY > 0)
      selectY--;
    selectX = min(targetCursorX, data.get(selectY).length());
  }
  void selectDown() {
    if(selectY < data.size()-1)
      selectY++;
    selectX = min(targetCursorX, data.get(selectY).length());
  }
  void removeLine(int y) {
    data.remove(y);
  }
  void setLine(int y, String s) {
    data.set(y, s);
  }
  void insertLine(int y) {
    data.add(y, "");
  }
  int getMaxLineLength() {
    int maxLength = 0;
    for(String s : data)
      if(s.length() > maxLength)
        maxLength = s.length();
    return maxLength;
  }
  int getMaxLineLengthTabToSpace() {
    int maxLength = 0;
    for(String s : data)
      if(tabToSpace(s).length() > maxLength)
        maxLength = tabToSpace(s).length();
    return maxLength;
  }
  public int countTabs(String s) {
    int out = 0;
    for(char c : s.toCharArray()) {
      if(c == '\t')
        out++;
      else
        break;
    }
    return out;
  }
  public String removeLast(String s) {
    String x = "";
    if(s.length() > 0)
      x = s.substring(0, s.length()-1);
    return x;
  }
  public String removeFrom(String s, int k) {
    String x = "";
    x = s.substring(0, k-1) + "" + s.substring(k, s.length()) + "";
    return x;
  }
  public String insertAt(String s, char c, int k) {
    return s.substring(0, k) + c + s.substring(k, s.length());
  }
  public String insertAt(String s, String c, int k) {
    return s.substring(0, k) + c + s.substring(k, s.length());
  }
  public boolean isWriteable(boolean coded, int c, int cc) {
    return !(cc == 67 && c == 3) && !(c == 22 && cc == 86) && ((!coded && c != BACKSPACE && c != ENTER && !isInRangeInclusive(c, 16, 18) && !isInRangeInclusive(c, 37, 40)) || cc == 222 || cc == 53 || cc == 55 || cc == 57);
  }
  public boolean isInRangeInclusive(int x, int a, int b) {
    for(int i = a; i <= b; i++)
      if(x == i)
        return true;
    return false;
  }
  public String tabToSpace(String s) {
    String o = "";
    for(char c : s.toCharArray()) {
      if(c == '\t')
        o += "      ";
      else
        o += c;
    }
    return o;
  }
  int TXS_SIZE = 0;
  float TXS_SPACING = .6f;
  void textSpecial(String s, float x, float y) {
    float currentPos = 0;
    for(int i = 0; i < s.length(); i++) {
      text(s.charAt(i), x + i*TXS_SIZE*TXS_SPACING, y);
    }
  }
  void textExtraSpecial(int startingIndex, String s, float x, float y) {
    //println(spaceForLetters + " " + startingIndex);
    if(startingIndex + s.length() - scrollX < 0 || startingIndex - scrollX > spaceForLetters) return;
    if(startingIndex + s.length() - scrollX < spaceForLetters && startingIndex - scrollX > 0) {
      textSpecial(s, x, y);
      return;
    }
    float currentPos = 0;
    for(int i = 0; i < s.length(); i++) {
      float textXPos = x + i*TXS_SIZE*TXS_SPACING;
      if(startingIndex + i - scrollX < spaceForLetters)
        if(startingIndex + i - scrollX >= 0)
          text(s.charAt(i), textXPos, y);
    }
  }
  void textRegularSpecial(int dataIndex, String s, float x, float y) {
    s = tabToSpace(data.get(dataIndex));
    int q = 0;
    String[] arr = s.split(String.format(WITH_DELIMITER, "\\."));
    float textX = 0.f;
    for(int i = 0; i < arr.length; i++) {
      textExtraSpecial(q, arr[i], x + textX - viewScrollX, y);
      textX += arr[i].length()*TXS_SIZE*TXS_SPACING;
      q += arr[i].length();
    }
  }
  ArrayList<String> objectNames = new ArrayList<String>();
  ArrayList<String> variableNames = new ArrayList<String>();
  ArrayList<String> functionNames = new ArrayList<String>();
  void textSpecialSyntax(int dataIndex, String s, float x, float y) {
    s = tabToSpace(data.get(dataIndex));
    int q = 0;
    if(syntax_highlight) {
      String[] arr = quoteSpaceDotSplit(s);
      float textX = 0.f;
      boolean inComment = false;
      for(int i = 0; i < arr.length; i++) {
        fill(border_color);
        if(arr[i].equals("return") || arr[i].equals("null") || arr[i].equals("true") || arr[i].equals("false") || arr[i].equals("public") || arr[i].equals("static") || arr[i].equals("final") || arr[i].equals("void") || arr[i].equals("protected") || arr[i].equals("package") || arr[i].equals("import") || arr[i].equals("class") || arr[i].equals("new")) fill(modifier_color);
        if(arr[i].equals("boolean") || arr[i].equals("float") || arr[i].equals("double") || arr[i].equals("char") || arr[i].equals("int")) fill(type_color);
        for(String r : objectNames)
          if(arr[i].equals(r)) fill(object_color);
        for(String r : variableNames)
          if(arr[i].equals(r)) fill(variable_color);
        for(String r : functionNames)
          if(arr[i].equals(r)) fill(function_color);
        if(arr[i].equals("if") || arr[i].equals("for") || arr[i].equals("while") || arr[i].equals("else") || arr[i].equals("do")) fill(loop_conditional_color);
        if(arr[i].equals("=") || arr[i].equals("==") || arr[i].equals("+=") || arr[i].equals("-=")) fill(operator_color);
        if(arr[i].contains("\"")) fill(string_color);
        if(arr[i].equals("//") || arr[i].equals("#") || arr[i].equals("*")) inComment = true;
        if(inComment) fill(comment_color);
        textExtraSpecial(q, arr[i], x + textX - viewScrollX, y);
        textX += arr[i].length()*TXS_SIZE*TXS_SPACING;
        q += arr[i].length();
      }
    } else {
      textRegularSpecial(dataIndex, s, x, y);
    }
  }
  void textSizeSpecial(int s) {
    textSize(s);
    TXS_SIZE = s;
  }
  int textWidthSpecial(String s) {
    return int(s.length()*TXS_SIZE*TXS_SPACING);
  }
  int lettersThatFitInto(float space) {
    quoteSpaceDotSplit("\thoop hoop hoop! ArrayList<String>() = \"Hello world!\";");
    return floor(space/(TXS_SIZE*TXS_SPACING)-1);
  }
  void rectSpecial(float x, float y, float w, float h) {
    float maxXText = px + TXS_SPACING*TXS_SIZE*spaceForLetters + offset;
    if(x + w > maxXText) {
      rect(x, y, w - ((x + w) - (maxXText)), h);
    } else
      rect(x, y, w, h);
  }
  public String[] quoteSplit(String s) {
    ArrayList<String> outlist = new ArrayList<String>();
    StringBuilder strb = new StringBuilder(32);
    char[] c = s.toCharArray();
    boolean inQuotes = false;
    for(int i = 0; i < c.length; i++) {
      if(c[i] == '\"' && !inQuotes) {
        outlist.add(strb.toString());
        inQuotes = true;
        strb = new StringBuilder(32);
        strb.append(c[i]);
      } else if(c[i] == '\"' && inQuotes) {
        strb.append(c[i]);
        outlist.add(strb.toString());
        inQuotes = false;
        strb = new StringBuilder(32);
      } else
        strb.append(c[i]);
    }
    outlist.add(strb.toString());
    return outlist.toArray(new String[outlist.size()]);
  }
  static public final String WITH_DELIMITER = "((?<=%1$s)|(?=%1$s))";
  public String[] quoteSpaceDotSplit(String s) {
    String[] spoot = quoteSplit(s);
    ArrayList<String> outlist = new ArrayList<String>();
    for(int i = 0; i < spoot.length; i++) {
      if(spoot[i].contains("\"")) {
        outlist.add(spoot[i]);
      } else {
        String[] d = spoot[i].split(String.format(WITH_DELIMITER, " |<|>|\\.|[(]|[)]|\\[|\\]|//|#|;"));
        for(String k : d)
          outlist.add(k);
      }
    }
    return outlist.toArray(new String[outlist.size()]);
  }
  public String getClipboard() {
    try {
      try {
      return (String)Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor);
      } catch(IOException ioe) {}
    } catch(UnsupportedFlavorException ufe) {}
    return "";
  }
  public void setClipboard(String s) {
    StringSelection stringSelection = new StringSelection(s);
    Clipboard clpbrd = Toolkit.getDefaultToolkit().getSystemClipboard();
    clpbrd.setContents(stringSelection, null);
  }
  public int containsNotInQuotes(String s, String regex) {
    String[] sArr = quoteSpaceDotSplit(s);
    int x = 0;
    for(String q : sArr) {
      if(q.contains(regex))
        return x;
      x += q.length();
    }
    return -1;
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}

class GoPad {
  float x;
  float y;
  float w;
  float h;
  float dr_x;
  float dr_y;
  float px;
  float py;
  float radius = 0.f;
  color border_color = color(255, 255);
  color fill_color = color(0, 255);
  boolean only_left_mouse_button = true;
  boolean sticky = false;
  boolean getting_input = false;
  float circle_radius = 14.f;
  float t = 0.f;
  float spin_speed = 0.f;
  float prev_millis = 0.f;
  boolean do_arcs = true;
  float sticky_easing_coefficent = 0.9f;
  float arc_speed_easing_coefficent = 0.97f;
  boolean bad_start = false;
  boolean was_mouse_in_bounds = false;
  boolean was_mouse_pressed = false;
  boolean display_values = false;
  float min_x = -1.f;
  float min_y = -1.f;
  float max_x = 1.f;
  float max_y = 1.f;
  float mx = -1.f;
  float mmx = 1.f;
  float my = -1.f;
  float mmy = 1.f;
  String var_x_name = "X";
  String var_y_name = "Y";
  float value_x = 0.f;
  float value_y = 0.f;
  public GoPad(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  public void set_range(float minx, float maxx, float miny, float maxy) {
    mx = minx;
    my = miny;
    mmx = maxx;
    mmy = maxy;
  }
  public void update() {
    if(!bad_start && !getting_input)
      if(was_mouse_pressed && !was_mouse_in_bounds && is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h))
        bad_start = true;
    if(!mousePressed)
      bad_start = false;
    
    if(!getting_input) {
      getting_input = mousePressed && is_in_bounds_exclusive(mouseX, mouseY, x, y, w, h);
      if(only_left_mouse_button && mouseButton != LEFT)
        getting_input = false;
    }
    if(!mousePressed || bad_start) getting_input = false;
    if(getting_input) {
      px = (float)mouseX - x - w/2.f;
      py = (float)mouseY - y - h/2.f;
      px = max(-w/2.f + circle_radius + 1, min(w/2.f - circle_radius - 1, px));
      py = max(-h/2.f + circle_radius + 1, min(h/2.f - circle_radius - 1, py));
    } else {
      if(!sticky) {
        px *= sticky_easing_coefficent;
        py *= sticky_easing_coefficent;
      }
    }
    dr_x = map(px, -w/2.f + circle_radius + 1, w/2.f - circle_radius - 1, min_x, max_x);
    dr_y = map(py, -h/2.f + circle_radius + 1, h/2.f - circle_radius - 1, min_y, max_y);
    PVector direction = new PVector(dr_x, dr_y);
    
    if(getting_input) {
      spin_speed = millis()/200.f - prev_millis;
    } else
      spin_speed *= arc_speed_easing_coefficent;
    
    value_x = map(dr_x, -1.f, 1.f, mx, mmx);
    value_y = map(dr_y, -1.f, 1.f, mmy, my);
    float r = sqrt(dr_x*dr_x + dr_y*dr_y);
    
    prev_millis = millis()/200.f;
    t += spin_speed;
    
    was_mouse_in_bounds = is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h);
    was_mouse_pressed = mousePressed;
  }
  public void display() {
    fill(fill_color);
    stroke(border_color);
    rect(x, y, w, h, radius);
    line(x, y + h/2.f, x + w, y + h/2.f);
    line(x + w/2.f, y, x + w/2.f, y + h);
    noFill();
    if(do_arcs) {
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius*2.f, circle_radius*2.f, t, t + 1.f);
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius*2.f, circle_radius*2.f, t + TWO_PI/3.f, t + 1.f + TWO_PI/3.f);
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius*2.f, circle_radius*2.f, t + TWO_PI/3.f*2.f, t + 1.f + TWO_PI/3.f*2.f);
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius, circle_radius, -t, -t + 1.f);
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius, circle_radius, -t + TWO_PI/3.f, -t + 1.f + TWO_PI/3.f);
      arc(x + w/2.f + px, y + h/2.f + py, circle_radius, circle_radius, -t + TWO_PI/3.f*2.f, -t + 1.f + TWO_PI/3.f*2.f);
    } else {
      ellipse(x + w/2.f + px, y + h/2.f + py, circle_radius*2.f, circle_radius*2.f);
      ellipse(x + w/2.f + px, y + h/2.f + py, circle_radius, circle_radius);
    }
    if(display_values) {
      textAlign(LEFT, TOP);
      fill(border_color);
      text(var_x_name + ": " + value_x, x + 10, y + 10);
      text(var_y_name + ": " + value_y, x + 10, y + 30);
      textAlign(LEFT, TOP);
    }
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}
  

class Button {
  float x;
  float y;
  float w;
  float h;
  float radius = 0.f;
  color border_color = color(255, 255);
  color fill_color = color(0, 255);
  boolean is_on;
  boolean toggle = false;
  boolean only_left_mouse_button = true;
  String name = "";
  boolean pmousePressed = false;
  boolean changed = false;
  boolean prev_is_on = false;
  public Button(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  public Button(float x, float y, float w, float h, String name) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.name = copy_str(name);
  }
  public void update() {
    if(mousePressed) {
      if(is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h)) {
        if(!(mousePressed && only_left_mouse_button && mouseButton != LEFT)) {
          if(toggle && !pmousePressed)
            is_on = !is_on;
          if(!toggle)
            is_on = true;
        }
      }
    } else {
      if(!toggle)
        is_on = false;
    }
    pmousePressed = mousePressed;
    if(is_on != prev_is_on)
      changed = true;
    else
      changed = false;
    prev_is_on = is_on;
  }
  public void display() {
    if(is_on)
      fill(border_color);
    else
      fill(fill_color);
    stroke(border_color);
    rect(x, y, w, h, radius);
    textAlign(CENTER, CENTER);
    if(is_on)
      fill(r(fill_color), g(fill_color), b(fill_color), 255);
    else
      fill(border_color);
    text(name, x + w/2, y + h/2);
    textAlign(LEFT, TOP);
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}

public class Slider {
  float value2; //0.0-1.1
  float value;
  float x;
  float y;
  float w;
  float h;
  float drag_bar_length;
  String name = "";
  boolean horizon;
  color border_color = color(255, 255);
  color fill_color = color(0, 255);
  float radius; //Curve radius on rectangle corners
  boolean display_value;
  float pmouse_x;
  float pmouse_y;
  float deltamouse_x;
  float deltamouse_y;
  boolean dragging;
  boolean only_left_mouse_button = true;
  boolean bad_start = false;
  boolean was_mouse_in_bounds = false;
  boolean was_mouse_pressed = false;
  float minimum = 0.f;
  float maximum = 1.f;
  boolean round_digits = false;
  int digits_to_round_to = 1;
  public Slider(float x, float y, float w, float h) {
    if(w > h) horizon = true;
    drag_bar_length = horizon ? h : w;
    this.x = x; this.y = y;
    this.w = w; this.h = h;
    pmouse_x = mouseX;
    pmouse_y = mouseY;
  }
  public Slider(float x, float y, float w, float h, String name) {
    if(w > h) horizon = true;
    drag_bar_length = horizon ? h : w;
    this.name = name;
    this.x = x; this.y = y;
    this.w = w; this.h = h;
    pmouse_x = mouseX;
    pmouse_y = mouseY;
  }
  public void set_range(float min, float max) {
    minimum = min;
    maximum = max;
  }
  public void set_value(float x) {
    value2 = map(x, minimum, maximum, 0.f, 1.f);
    value = x;
  }
  void update() {
    if(!bad_start && !dragging)
      if(was_mouse_pressed && !was_mouse_in_bounds && is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h))
        bad_start = true;
    if(!mousePressed)
      bad_start = false;
    
    if(!(mousePressed && only_left_mouse_button && mouseButton != LEFT)) {
      deltamouse_x = mouseX - pmouse_x;
      deltamouse_y = mouseY - pmouse_y;
      pmouse_x = mouseX;
      pmouse_y = mouseY;
      boolean b = false;
      if(horizon)
        if(mousePressed && is_in_bounds_inclusive(mouseX, mouseY, map(value2, 0.0f, 1.0f, x, x + w - drag_bar_length), y, drag_bar_length, h))
          dragging = true;
      else
        if(mousePressed && is_in_bounds_inclusive(mouseX, mouseY, x, map(value2, 0.0f, 1.0f, y, y + h - drag_bar_length), w, drag_bar_length))
            dragging = true;
      if(!mousePressed)
        dragging = false;
    }
    
    if(bad_start) dragging = false;
    
    if(dragging) {
      if(horizon)
        value2 += deltamouse_x/(w - drag_bar_length);
    }
    value2 = max(0.0, min(1.0, value2));
    value = map(value2, 0.f, 1.f, minimum, maximum);
    was_mouse_in_bounds = is_in_bounds_inclusive(mouseX, mouseY, x, y, w, h);
    was_mouse_pressed = mousePressed;
  }
  void display() {
    textAlign(CENTER, BOTTOM);
    fill(fill_color);
    stroke(border_color);
    rect(x, y, w, h, radius);
    if(dragging)
      fill(border_color);
    if(horizon) {
      rect(map(value2, 0.0f, 1.0f, x, x + w - drag_bar_length), y, drag_bar_length, h, radius);
      fill(border_color);
      text(name, x + w/2, y + h/2 + 2);
      if(display_value) {
        if(dragging)
          fill(r(fill_color), g(fill_color), b(fill_color), 255);
        textAlign(CENTER, TOP);
        if(round_digits) {
          String s = round_to(map(value2, 0.f, 1.f, minimum, maximum), digits_to_round_to);
          text(s, map(value2, 0.0f, 1.0f, x + drag_bar_length/2, x + w - drag_bar_length/2), y + h/2 + 2);
        } else {
          text(map(value2, 0.f, 1.f, minimum, maximum), map(value2, 0.0f, 1.0f, x + drag_bar_length/2, x + w - drag_bar_length/2), y + h/2 + 2);
        }
      }
    } else {
      rect(x, map(value2, 0.0f, 1.0f, y, y + h - drag_bar_length), w, drag_bar_length, radius);
    }
    textAlign(LEFT, TOP);
  }
  public void set_theme(Theme t) {
    this.fill_color = t.fill_color;
    this.border_color = t.border_color;
    this.radius = t.radius;
  }
}

class Theme {
  color fill_color;
  color border_color;
  float radius = 0.f;
  public Theme(color f, color b) {
    fill_color = f;
    border_color = b;
  }
}
