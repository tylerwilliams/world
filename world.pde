import processing.net.*;
import org.json.*;
Client myClient; 
String socketBuffer;

int numParticles = 200;
int impulsX = 0;
int impulsY = 0;
int impulsToX = 0;
int impulsToY = 0;

//var last_segment = null;
//var last_section = null;
//var last_bar = null;
//var last_beat = null;
//var last_tatum = null;
//var beat_count = 0;
//var avg_loudness_factor;
//var curr_height;
//var curr_width;

Star stars[];

/*
  Simple 2D point
*/
class Point {
  int x, y;
  Point(int ax, int ay) {
    x = ax;
    y = ay;
  }
}


class Star {
	float current_size;
	float next_size;
	float angle, speedX, speedY;
	int flightMode;
	float degree, degreeSpeed;
	int frame;
	color current_color, next_color;
	Point current_position, next_position;
	Star () {
		int start_x = int(random(width));
		current_position = new Point(start_x, height/2);
		next_position = new Point(start_x, height/2);
		angle = random(1)*2*PI;
		current_size = 0;
		next_size = random(4)+1;
		current_color = color(0,0,0);
		next_color = color(random(255), random(255), random(255));
		speedX = 0;
		speedY = 0;
		degree = int(random(180));
		degreeSpeed = 0;
		frame = 0;
	}
	void draw() {
		// update positions from next_position
		current_position.x = current_position.x + (next_position.x - current_position.x) / 10;
		current_position.y = current_position.y + (next_position.y - current_position.y) / 10;
		
		// then update next_position
		next_position.x += speedX;
		next_position.y += speedY;
		
		// check for bounds
		if(current_position.x < 0) {
			current_position.x = width;
			next_position.x = width;
		}
		if(current_position.x > width) {
			current_position.x = 0;
			next_position.x = 0;
		}
		
		if(current_position.y < 0) {
			current_position.y = height;
			next_position.y = height;
		}
		if(current_position.y > height) {
			current_position.y = 0;
			next_position.y = 0;
		}
		
		// update size
		current_size = current_size + (next_size - current_size) / 10;
		// update color
		color diff = (next_color - current_color);
		current_color += color(red(diff)/10, green(diff)/10, blue(diff)/10, 0);
		
		// add impuls
		next_position.x += Math.floor(impulsX * current_size/30);
		next_position.y += Math.floor(impulsY * current_size/30);
		
		// draw
		fill(current_color, 255);
		ellipse(current_position.x, current_position.y, current_size, current_size);
	}
}

// scene transitions
void random_position(Star[] stars) {
	Star p;
	for (int i=0; i<stars.length; i++) {
		p = stars[i];
		p.next_position = new Point(int(random(width)), int(random(height)));
		p.speedX = cos(p.angle) * random(1);
		p.speedY = cos(p.angle) * random(1);
	}
}

void white_flash(Star[] stars) {
	Star p;
	for (int i=0; i<stars.length; i++) {
		p = stars[i];
		p.current_color = color(255,255,255,250);
		p.current_size = random(0,100);
	}
}

void pulse(Star[] stars) {
	Star p;
	for (int i=0; i<stars.length; i++) {
		p = stars[i];
		p.current_size = p.current_size*1.8;
	}
}

void change_size(Star[] stars) {
	Star p;
	for (int i=0; i<stars.length; i++) {
		p = stars[i];
		p.next_size = random(1,11);
	}
}

void circle_shape(Star[] stars) {
	int r = floor(random(100,350));
	for (int i=0; i<stars.length; i++) {
		Star p = stars[i];
		p.next_size = random(1,5);
		p.next_position = new Point(int(width/2 + cos(i*3.6*PI/180)*r), int(height/2 + sin(i*3.6*PI/180)*r));
		impulsX = 0;
		impulsY = 0;
		p.speedX = random(-.25,.25);
		p.speedY = random(-.25,.25);
	}
}

void heart(Star[] stars) {
	Star a,b;
	
	int count = 0;
	float inc = 60.0/(stars.length/2);
	float i = 0;
	while ((i<60.0) && (count < stars.length)) {
		a = stars[count++];
		b = stars[count++];
		float dx = .2*(-(i*i) + 40*i + 1200)*sin(PI*i/180);
		float dy = .2*(-(i*i) + 40*i + 1200)*cos(PI*i/180);
		float x = width/2;
		float y = height/1.5;
		a.next_position = new Point(int(x+dx),int(y-dy));
		b.next_position = new Point(int(x-dx),int(y-dy));
		a.speedX = random(-.25,.25);
		a.speedY = random(-.25,.25);
		b.speedX = random(-.25,.25);
		b.speedY = random(-.25,.25);
		i = i + inc;
	}
	impulsX = 0;
	impulsY = 0;
}

void setup() {
	size(800, 600);
	stars = new Star[numParticles];
	for (int i=0; i<numParticles; i++) {
		stars[i] = new Star();
		stars[i].speedX = 0;
		stars[i].speedY = 0;
	}
	size(width, height);
	noStroke();
	frameRate(30);
	fill(0,0,0);
	background(0,0,0);
        myClient = new Client(this, "127.0.0.1", 6500);
//	enable_sections()
//	enable_segments();
//	enable_bars();
//	enable_beats();
	//enable_tatums();
}

class Controller {
	Controller () {
	}
	void transit() {
		int f = floor(random(2));
		if (f==0) {
			circle_shape(stars);
		}
		else if (f==1) {
			heart(stars);
		}
		else {
			println(f);
		}
	}
}

void handlePacket(String raw_string) {
  try {
    JSONObject myData = new JSONObject(raw_string);
    String action = myData.getString("action");
    
    if (action.equals("beat")) {
      println("got beat message");
      beat();
    }
    else if (action.equals("bar")) {
      println("got bar message");
      bar();
    }
    else if (action.equals("flash")) {
      println("got flash message");
      flash();
    }
    else if (action.equals("segment")) {
      println("got segment message");
      segment();
    }
    else if (action.equals("section")) {
      println("got section message");
      section();
    }
    else {
      println("got unknown message");
    }
  } catch (JSONException e) {
    println("There was an error parsing the JSONObject.");
    println(raw_string);
  };
}


void update() {
	impulsX = impulsX + (impulsToX - impulsX) / 30;
	impulsY = impulsY + (impulsToY - impulsY) / 30;

        if (myClient.available() > 0) { 
          socketBuffer = myClient.readString();
          handlePacket(socketBuffer);
//          println("recieved: "+socketBuffer);
        }
}

void beat() {
  pulse(stars);
}

void bar() {
  impulsX = int(random(-width/2, width/2));
  impulsY = int(random(-height/2, height/2));
}

void flash() {
  white_flash(stars);
}

void segment() {
    int r1 = floor(random(stars.length));
    int r2 = floor(random(stars.length));

    stars[r1].current_size = int(random(40));
    stars[r2].current_size = int(random(40));
}

void section() {
    	int f = floor(random(2));
       	if (f==0) {
          circle_shape(stars);
        }
        else if (f==1) {
          heart(stars);
        }
}
  
  
//	if (!window.current_track) {
//	int r1 = floor(random(stars.length));
//	int r2 = floor(random(stars.length));
//		
//	stars[r1].current_size = int(random(40));
//	stars[r2].current_size = int(random(40));
//	}
//	else {
//		if (window.timestamp < window.current_track.end_of_fade_in) {
//			int r1 = floor(random(stars.length));
//			int r2 = floor(random(stars.length));
//			
//			stars[r1].current_size = int(random(40));
//			stars[r2].current_size = int(random(40));
//		}
//		if ((window.beat) && (window.beat != last_beat)) {
//			last_beat = window.beat;
//			pulse(stars);
//		}
//		
//		if ((window.bar) && (window.bar != last_bar)) {
//			last_bar = window.bar;
//			if (window.bar.confidence > .1) {
//				impulsX = int(random(-width/2, width/2));
//				impulsY = int(random(-height/2, height/2));
//			}
//		}
//		
//		if ((window.segment) && (window.segment != last_segment)) {
//			last_segment = window.segment;
//			if (loudness_factor(window.segment.loudness) > loudness_factor(window.current_track.overall_loudness)) {
//				white_flash(stars);
//			}
//			int r1 = floor(random(stars.length));
//			int r2 = floor(random(stars.length));
//			
//			stars[r1].current_size = int(random(40));
//			stars[r2].current_size = int(random(40));
//		}
//		
//		if ((window.section) && (window.section != last_section)) {
//			last_section = window.section;
//			int f = floor(random(2));
//		   	if (f==0) {
//		      circle_shape(stars);
//		    }
//		    else if (f==1) {
//		      heart(stars);
//		    }
//		    else {
//		      println(f);
//		    }
//		}
////	}
	
//	resized = false;


void draw() {
	background(0);
	update();
	for (int i=0; i<stars.length; i++) {
		Star p = stars[i];
		p.draw();
	}
}
  
