import java.util.Arrays;
import java.util.Collections;

// Haptic Feedback
import android.app.Activity;
import android.content.Context;
import android.os.Vibrator;
import android.os.VibrationEffect;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 456; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

// The left edge of the input area
float leftEdge;

// Where the keys start
float topOfKeys;

float last_mouseX;
float last_mouseY;

//Variables for my silly implementation. You can delete this:
String currentLetter = "a";

boolean first_press = false;
boolean first_release = false;

// Class for each square
// Contains the letters for each square
class KeySquare 
{
  public String center = "";
  public String left = "";
  public String top = "";
  public String right = "";
  public String bottom = "";

  public void display(int row, int col){
    stroke(255);
    strokeWeight(1);
    fill(105);

    rect(leftEdge + 152*col, topOfKeys + 121*row, 152, 121);

    float centerX = leftEdge + 152*col + 76;
    float centerY = topOfKeys + 121*row + 65;

    fill(255);
    text(center, centerX, centerY);

    text(left, centerX - 50, centerY);
    text(right, centerX + 50, centerY);
    text(top, centerX, centerY - 40);
    text(bottom, centerX, centerY + 40);
  }
}

// The list of squares
KeySquare[] squares;

// Haptic feedback event
Activity act;

//Displaying diagnostics
float adjusted_WPM;
float accuracy;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be PORTRAIT -- sets orientation on android device
  size(1300, 2300); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("arial.ttf", 36)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  leftEdge = width/2-sizeOfInputArea/2 - 100;
  topOfKeys = height/2 - sizeOfInputArea/2 + sizeOfInputArea/5;

  // Haptic feedback stuff
  act = this.getActivity();

  squares = initKeys();
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(105); //clear background

  drawWatch();
  fill(105);
  rect(width/2-sizeOfInputArea/2 - 100, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    text("Accuracy: " + ((1 - accuracy)*100), 280, 200);
    text("Adjusted WPM: " + adjusted_WPM, 280, 250);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 550); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(255);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 550); //draw the trial count
    text("Target:   " + currentPhrase, 70, 600); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 640); //draw what the user has entered thus far 
    
    //draw very basic next button
    fill(0, 255, 0);
    rect(800, 350, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 850, 450); //draw next label

    //my draw code
    // Black outlines
    textAlign(CENTER);

    fill(105);
    stroke(255);
    strokeWeight(4);

    squares[6].center = predict();

    for(int row = 0; row < 3; row += 1){
      for(int col = 0; col < 3; col += 1){
        squares[row * 3 + col].display(row, col);
      }
    }

    stroke(0);
    strokeWeight(1);

    // fill(0, 255, 0); //green button
    // rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    fill(255);
    text("" + currentLetter, width/2 - 100, height/2-sizeOfInputArea/3 - 10); //draw current letter
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{

  Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
  VibrationEffect effect = VibrationEffect.createOneShot(25,2);
  vibrer.vibrate(effect);

  if(first_press == false){
    first_press = true;
    return;
  }

  if(didMouseClick(leftEdge, topOfKeys, sizeOfInputArea, 364)){
    int clickedRow = floor((mouseY - topOfKeys)/121);
    int clickedCol = floor((mouseX - leftEdge)/152);
    int clickedIndex = clickedRow * 3 + clickedCol;

    last_mouseX = mouseX;
    last_mouseY = mouseY;

    // If they hit the autocomplete button
    if(clickedIndex == 6){
      first_release = false;
      if (predict().equals("is")){
        currentTyped += "s";
        currentLetter = "is";
      }
      else if(predict().equals("of")){
        currentTyped += "f";
        currentLetter = "of";
      }
      else if(predict().equals("for")){
        currentTyped += "or";
        currentLetter = "for";
      }
      else{
        // If this is being predicted entirely
        if(currentLetter.equals("t")){
          currentTyped += "he";
          currentLetter = "the";
        }
        else{
          currentTyped += "the";
          currentLetter = "the";
        }
      }
    } else if(clickedIndex == 8){
      currentLetter = "\u2A3D\u2A3C";
      currentTyped += " ";
      first_release = false;
    }
  }
  

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(800, 350, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased(){
  float delta_x = mouseX - last_mouseX;
  float delta_y = mouseY - last_mouseY;

  if(!first_release){
    first_release = true;
    return;
  }

  int clickedRow = floor((last_mouseY - topOfKeys)/121);
  int clickedCol = floor((last_mouseX - leftEdge)/152);
  int clickedIndex = clickedRow * 3 + clickedCol;

  // Close enough to center
  if(abs(delta_x) <= 30 && abs(delta_y) <= 30){
    if(squares[clickedIndex].center.equals("") == false){
      currentLetter = squares[clickedIndex].center;
      currentTyped += squares[clickedIndex].center;
    }
  }
  // Further horizontal than vertical
  else if(abs(delta_x) >= abs(delta_y)){
    // Right swipe
    if(delta_x > 0){
      if(squares[clickedIndex].right.equals("") == false){
        currentLetter = squares[clickedIndex].right;
        currentTyped += squares[clickedIndex].right;
      }
    }
    else {// left swipe
      if(squares[clickedIndex].left.equals("") == false){
        currentLetter = squares[clickedIndex].left;
        currentTyped += squares[clickedIndex].left;
      }
    }
  }
  // Further vertical than horizontal
  else{
    // Down swipe
    if(delta_y > 0){
      if(squares[clickedIndex].bottom.equals("") == false){
        currentLetter = squares[clickedIndex].bottom;
        currentTyped += squares[clickedIndex].bottom;
      }
    }
    else {
      if(squares[clickedIndex].top.equals("") == false){
        currentLetter = squares[clickedIndex].top;
        currentTyped += squares[clickedIndex].top;
      }
    }
  }
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    System.out.println("Raw WPM: " + wpm); //output

    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars

    System.out.println("Freebie errors: " + freebieErrors); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    adjusted_WPM = wpm - penalty;
    accuracy = errorsTotal/lettersExpectedTotal;

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2 - 100,height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch,0,0);
  popMatrix();
}

// Function to return next word prediction
String predict()
{
  if(currentLetter.equals("i")){
    return "is";
  }
  else if (currentLetter.equals("f")){
    return "for";
  }
  else if (currentLetter.equals("o")){
    return "of";
  }
  return "the";
}


KeySquare[] initKeys()
{
  KeySquare topLeft = new KeySquare();
  topLeft.center = "a";
  topLeft.right = "b";
  topLeft.bottom = "c";

  KeySquare topMiddle = new KeySquare();
  topMiddle.center = "d";
  topMiddle.left = "e";
  topMiddle.bottom = "g";
  topMiddle.right = "f";

  KeySquare topRight = new KeySquare();
  topRight.center = "h";
  topRight.left = "i";
  topRight.bottom = "j";

  KeySquare middleLeft = new KeySquare();
  middleLeft.center = "k";
  middleLeft.top = "l";
  middleLeft.right = "m";
  middleLeft.bottom = "n";

  KeySquare middle = new KeySquare();
  middle.center = "o";
  middle.top = "p";
  middle.left = "q";
  middle.right = "r";
  middle.bottom = "s";

  KeySquare middleRight = new KeySquare();
  middleRight.center = "t";
  middleRight.top = "u";
  middleRight.left = "v";
  middleRight.bottom = "w";

  // We'll fill this one with predictive text
  KeySquare bottomLeft = new KeySquare();

  KeySquare bottomMiddle = new KeySquare();
  bottomMiddle.center = "x";
  bottomMiddle.left = "y";
  bottomMiddle.right = "z";

  // Space bar
  KeySquare bottomRight = new KeySquare();
  bottomRight.center = "\u2A3D\u2A3C";

  KeySquare[] squares = {topLeft, topMiddle, topRight, middleLeft, middle,
                           middleRight, bottomLeft, bottomMiddle, bottomRight};

  return squares;
}

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}