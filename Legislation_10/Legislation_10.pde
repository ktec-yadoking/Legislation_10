import processing.sound.*;

Player player1;
Player player2;
boolean is_GameStarted = false;
boolean is_GameOver = false;
int StartCount = 3;
int s_count=0;
int o_count=0;
int _winner;
boolean is_pressed_1, is_pressed_2;
PImage blocks_img[] = new PImage[10];
PImage bg, plus, minus, multiply, divide, ready, go,start,home,retry,win,lose,title;
SoundFile m_bgm, m_put, m_attack, m_hinder, m_hold;
int STOP=50;
class Player {
  String[][] _stage = new String[7][4];
  String[] _number_set1 = new String[10];
  String[] _number_set2 = new String[10];
  String[] _sign_set1 = new String[6];
  String[] _sign_set2 = new String[6];
  String _now, _hold="0";
  boolean _is_holded,_is_gameover,_hinding;
  int _x, _y, _drop_count, _hinder_left, _attack_hinder;
  int _sry=1;
  int _stop=0;
  char _next_type;
  
  void setup() {
    for (int i=0; i<7; i++) {
      for (int j=0; j<4; j++) {
        _stage[i][j]="0";
      }
    }
    _number_set1 = make_blocks("number");
    _number_set2 = make_blocks("number");
    _sign_set1 = make_blocks("sign");
    _sign_set2 = make_blocks("sign");
    reset_now();
    _attack_hinder=0;
  }

  void draw() {
    if (_hinding) {
      check_calculate_block(_stage);
      block_arrange(_stage);
      _hinding=false;
      is_gameover();
    }
    down_block(_stage, _now, _x);
  }

  void onPressed_A() {//move<-
    if (0<_x) {
      if(_stage[_y][_x-1]=="0"){
        _x-=1;
      }
    }
  }
  void onPressed_D() {//move->
    if (_x<3) {
      if(_stage[_y][_x+1]=="0"){
        _x+=1;
      }
    }
  }
  void onPressed_W() {//drop
    m_put.play();
    drop_block(_stage, _now, _x);
    check_calculate_block(_stage);
    for (int i=0; i<2; i++) {
      if (_hinder_left>0) {
        m_hinder.play();
        drop_block(_stage, "10", hinder_index());
        _stop=1;
        _hinding=true;
      }
      else{
        is_gameover();
      }
    }
    block_arrange(_stage);
  }

  void onPressed_Q() {//hold
    m_hold.play();
    hold_block();
  }
  
  void reset_now() {
    _now = get_next_block(_number_set2, _sign_set2);
    _x=1;
    _y=0;
  }

  //以下部員が作った関数
  String[] make_blocks(String type) {
    String[] hairetsu_number={"1", "2", "3", "4", "5", "6", "7", "8", "9"};
    String[] hairetsu_sign={"+", "+", "+", "-", "-", "-"};
    int tempa, tempb;
    String ransu, tempc, tempd;
    if (type=="number") {
      for (int i=0; i<floor(random(100, 200)); i++) {
        tempa=floor(random(0, 9));
        tempb=floor(random(0, 9));
        tempc=hairetsu_number[tempa];
        tempd=hairetsu_number[tempb];
        hairetsu_number[tempa]=tempd;
        hairetsu_number[tempb]=tempc;
      }
      return hairetsu_number;
    } else if (type=="sign") {
      for (int i=0; i<floor(random(100, 200)); i++) {
        tempa=floor(random(0, 6));
        tempb=floor(random(0, 6));
        tempc=hairetsu_sign[tempa];
        tempd=hairetsu_sign[tempb];
        hairetsu_sign[tempa]=tempd;
        hairetsu_sign[tempb]=tempc;
      }
      return hairetsu_sign;
    } else {
      return null;
    }
  }

  String get_next_block(String[] numbers, String[] signs) {
    int num_sign_zero = zero_count(numbers, signs);
    String temp_return;
    if (num_sign_zero%2==0) {
      temp_return=_number_set1[0];
      update_lists("number");
      _next_type='s';
    } else {
      temp_return=_sign_set1[0];
      update_lists("sign");
      _next_type='n';
    }
    if (zero_count(_number_set2, _sign_set2)%2==0) {
      _next_type='n';
    } else {
      _next_type='s';
    }
    int not_zero_count = 0;
    for (int i=0; i<_number_set2.length; i++) {
      if (_number_set2[i]!="0") {
        not_zero_count+=1;
      }
    }
    _sry=not_zero_count;
    return temp_return;
  }

  int zero_count(String[] numbers, String[] signs) {
    int numbers_count=0;
    int signs_count=0;
    for (int i=0; i<numbers.length; i++) {
      if (numbers[i]=="0") {
        numbers_count+=1;
      }
    }
    for (int i=0; i<signs.length; i++) {
      if (signs[i]=="0") {
        signs_count+=1;
      }
    }
    return numbers_count+signs_count;
  }

  void update_lists(String type) {
    if (type=="number") {
      for (int i=0; i<_number_set1.length-1; i++) {
        _number_set1[i]=_number_set1[i+1];
      }
      _number_set1[_number_set1.length-1]=_number_set2[0];
      for (int i=0; i<_number_set2.length-1; i++) {
        _number_set2[i]=_number_set2[i+1];
      }
      _number_set2[_number_set2.length-1]="0";
      int zerocheck=0;
      for (int i=0; i<_number_set2.length; i++) {
        if (_number_set2[i]=="0") {
          zerocheck++;
        }
      }
      if (zerocheck==_number_set2.length) {
        _number_set2=make_blocks("number");
      }
    }
    if (type=="sign") {
      for (int i=0; i<_sign_set1.length-1; i++) {
        _sign_set1[i]=_sign_set1[i+1];
      }
      _sign_set1[_sign_set1.length-1]=_sign_set2[0];
      for (int i=0; i<_sign_set2.length-1; i++) {
        _sign_set2[i]=_sign_set2[i+1];
      }
      _sign_set2[_sign_set2.length-1]="0";
      int zerocheck=0;
      for (int i=0; i<_sign_set2.length; i++) {
        if (_sign_set2[i]=="0") {
          zerocheck++;
        }
      }
      if (zerocheck==_sign_set2.length) {
        _sign_set2=make_blocks("sign");
      }
    }
  }

  String[][] drop_block(String[][] stage, String value, int index) {
    if (index == 4) {
      _is_holded = false;
      return stage;
    } else {
      if (value!="10") {
        reset_now();
      }
      for (int i=0; i<6; i+=1) {
        if (stage[i+1][index] != "0") {
          stage[i][index] = value;
          _is_holded = false;
          return stage;
        } else {
          stage[i+1][index]=value;
          stage[i][index] = "0";
        }
      }
      stage[6][index]=value;
    }
    return stage;
  }

  String[][] block_arrange(String[][] arrange_stage) {
    for (int i = 0; i < arrange_stage[0].length; i ++) {
      for (int j = 0; j < arrange_stage.length -1; j ++) {
        if (arrange_stage[j][i] != "0" && arrange_stage[j + 1][i] == "0") {
          arrange_stage[j + 1][i] = arrange_stage[j][i];
          arrange_stage[j][i] = "0";
        }
      }
    }
    return arrange_stage;
  }

  String[][] check_calculate_block(String[][] calculate_stage) {
    String symbol[] = {"+", "-", "*", "/"};
    String figure[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"};
    for (int i = 0; i < calculate_stage[0].length; i ++) {
      for (int j = 0; j < calculate_stage.length-1; j ++) {
        for (int k = 0; k < symbol.length; k++) {
          if (calculate_stage[j][i] == symbol[k]) { // whether symbols exist or not

            if (calculate_stage[j + 1][i] == symbol[k]) { // evolution of symbols
              if (symbol[k] == "+") {
                calculate_stage[j][i] = "0";
                calculate_stage[j + 1][i] = "*";
              } else if (symbol[k] == "-") {
                calculate_stage[j][i] = "0";
                calculate_stage[j + 1][i] = "/";
              }
              return calculate_stage;
            } else if (j != 7 && j != 0) { // for escaping "out of bounds"
              for (int l = 0; l < figure.length; l ++) {
                if (int(calculate_stage[j + 1][i]) == int(figure[l])) {
                  for (int m = 0; m < figure.length; m ++) {
                    if (int(calculate_stage[j - 1][i]) == int(figure[m])) {
                      float result = 0;
                      if (k == 0) {
                        result = int(figure[m]) + int(figure[l]);
                      } else if (k == 1) {
                        result = int(figure[m]) - int(figure[l]);
                      } else if (k == 2) {
                        result = int(figure[m]) * int(figure[l]);
                      } else if (k == 3) {
                        result = float(figure[m]) /float(figure[l]);
                        result = round(result);
                      }
                      if (result > 10) {
                        result = result % 10;
                      } else if (result < 0) {
                        result = result + 10;
                      }
                      if (result == 10 || result == 0) {
                        for (int o = -1; o < 2; o ++) {
                          calculate_stage[j + o][i] = "0";
                        }
                        m_attack.play();
                        _attack_hinder+=2;
                      } else {
                        for (int o = -1; o < 2; o ++) {
                          if (o == 1) {
                            calculate_stage[j + o][i] = str(int(result));
                          } else {
                            calculate_stage[j + o][i] = "0";
                          }
                        }
                      }
                      //return calculate_stage;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return calculate_stage;
  }

  void hold_block() {
    if (!_is_holded) {
      if (_hold == "0") {
        _hold = _now;
        _now = get_next_block(_number_set2, _sign_set2);
        _y=0;
        _is_holded=true;
        drop_block(_stage, "0", 4);
      } else {
        String temp = _hold;
        _hold = _now;
        _now = temp;
        _y=0;
        _is_holded=true;
      }
    }
  }

  void down_block(String[][] stage, String value, int index) {
    if (_drop_count>=180) {
      if (_y==6||stage[_y+1][index]!="0") {
        _stage=stage;
        _now=value;
        _x=index;
        onPressed_W();
      }
      _y+=1;
      _drop_count=0;
    } else {
      _drop_count+=1;
    }
  }

  int hinder_index() {
    int zero_num;
    int[] tf=new int [4];
    int retsu;
    int retsu2;
    zero_num=0;
    for (int i=0; i<4; i++) {
      if (_stage[i][1]=="0") {
        tf[i]=0;
        zero_num += 1;
      } else {
        tf[i]=1;
      }
    }
    if (zero_num==0) {
      return 4;
    }
    retsu = int(random(0, zero_num-0.1));
    //print(zero_num);
    retsu2=retsu;
    for (int i=0; i<retsu+1; i++) {
      if (tf[i]==1) {
        retsu2+=1;
      }
    }
    _hinder_left -= 1;
    return retsu2;
  }
  //以上部員が作った関数

  boolean is_gameover() {
    for (int i=0; i<4; i++) {
      if (_stage[0][i]!="0") {
        _is_gameover=true;
        return true;
      }
    }
    return false;
  }
  int[] get_block_position(int player, int x, int y) {
    int[] return_pos = new int[2];
    if (player==1) {
      return_pos[0]=(64*x)+100;
      return_pos[1]=(64*y)+100;
    } else {
      return_pos[0]=(64*x)+100;
      return_pos[1]=(64*y)+100;
    }
    return return_pos;
  }
  int[] get_difference(int[][] stage1, int[][] stage2) {
    for (int i=0; i<6; i++) {
      for (int j=0; j<4; j++) {
        if (stage1[j][i]!=stage2[j][i]) {
          int[] ji = new int[2];
          ji[0]=j;
          ji[1]=i;
          return ji;
        }
      }
    }
    return null;
  }
}


void setup() {
  size(1024, 896);
  player1=new Player();
  player2=new Player();
  for (int i=1; i<=10; i++) {
    blocks_img[i-1] = loadImage("asset/picture/"+str(i)+".png");
  }
  player1.setup();
  player2.setup();
  
  title=loadImage("asset/picture/logodot_final.png");
  
  start=loadImage("asset/picture/astart.png");
  home=loadImage("asset/picture/bhome.png");
  retry=loadImage("asset/picture/aretry.png");
  win=loadImage("asset/picture/win.png");
  lose=loadImage("asset/picture/lose.png");
  
  bg=loadImage("asset/picture/bg.png");
  plus=loadImage("asset/picture/plus_candidate.png");
  minus=loadImage("asset/picture/minus_candidate.png");
  multiply=loadImage("asset/picture/multiply_candidate.png");
  divide=loadImage("asset/picture/divide_candidate.png");
  
  ready=loadImage("asset/picture/READY.png");
  go=loadImage("asset/picture/GO.png");

  m_bgm = new SoundFile(this, "asset/sound/bgm1.wav");
  m_put = new SoundFile(this, "asset/sound/put.mp3");
  m_attack = new SoundFile(this, "asset/sound/attack.mp3");
  m_hinder = new SoundFile(this, "asset/sound/hinder.mp3");
  m_hold = new SoundFile(this, "asset/sound/hold.mp3");
  m_bgm.loop();
  m_bgm.play();
}

void draw() {
  if(!is_GameStarted){
    image(bg, 0, 0, 1024, 896);
    image(title,2,640,1020,240);
    drawSelect_start();
    if(keyPressed){
      if(key=='s'){
        is_GameStarted=true;
      }
    }
  }
  else if(0<StartCount){
    image(bg, 0, 0, 1024, 896);
    s_count+=1;
    if(StartCount==3){
      image(ready, 152, 288,96,64);
      image(ready, 776, 288,96,64);
    }else if(StartCount==2){
      image(ready, 152, 608,96,64);
      image(go, 152, 288,96,64);
      image(ready, 776, 608,96,64);
      image(go, 766, 288,96,64);
    }else{
      s_count+=2;
      image(ready, 152, 608,96,64);
      image(go, 152, 544,96,64);
      image(ready, 766, 608,96,64);
      image(go, 766, 544,96,64);
    }
    if(s_count>60){
      StartCount-=1;
      s_count=0;
    }
  }
  else if (!is_GameOver) {
    image(bg, 0, 0, 1024, 896);
    //add hinder block
    while (player1._attack_hinder>0) {
      player1._attack_hinder-=1;
      player2._hinder_left+=1;
    }
    while (player2._attack_hinder>0) {
      player2._attack_hinder-=1;
      player1._hinder_left+=1;
    }
    //keyHandle
    if (keyPressed) {//Player2の場合は a -> j  d->l  w->i  q->u
      //player1
      if (player1._stop==0) {
        if (key=='a') {
          if (!is_pressed_1) {
            is_pressed_1=true;
            player1.onPressed_A();
          }
        } else if (key=='d') {
          if (!is_pressed_1) {
            is_pressed_1=true;
            player1.onPressed_D();
          }
        } else if (key=='w') {
          if (!is_pressed_1) {
            is_pressed_1=true;
            player1.onPressed_W();
          }
        } else if (key=='q') {
          if (!is_pressed_1) {
            is_pressed_1=true;
            player1.onPressed_Q();
          }
        } else {
          is_pressed_1=false;
        }
      }
      //player2
      if (player2._stop==0) {
        if (key=='j') {
          if (!is_pressed_2) {
            is_pressed_2=true;
            player2.onPressed_A();
          }
        } else if (key=='l') {
          if (!is_pressed_2) {
            is_pressed_2=true;
            player2.onPressed_D();
          }
        } else if (key=='i') {
          if (!is_pressed_2) {
            is_pressed_2=true;
            player2.onPressed_W();
          }
        } else if (key=='u') {
          if (!is_pressed_2) {
            is_pressed_2=true;
            player2.onPressed_Q();
          }
        } else {
          is_pressed_2=false;
        }
      }
    } else {
      is_pressed_1=false;
      is_pressed_2=false;
    }
    if (player1._stop==0) {
      player1.draw();
    } else {
      player1._stop+=1;
      if (player1._stop>STOP) {
        player1._stop=0;
      }
    }
    if (player2._stop==0) {
      player2.draw();
    }else {
      player2._stop+=1;
      if (player2._stop>STOP) {
        player2._stop=0;
      }
    }
    //GameOverCheck
    if (player1._is_gameover) {
      is_GameOver=true;
      _winner=2;
    }
    if (player2._is_gameover) {
      is_GameOver=true;
      _winner=1;
    }
    //visualize
    drawblocks();
  }
  else if(is_GameOver){
    o_count+=1;
    drawJudge(_winner);
    if(o_count>120){
      drawSelect_over();
      if(keyPressed){
        if(key=='s'){
          reset(false);
        }else if(key=='h'){
          reset(true);
        }
      }
    }
  }
}

void keyReleased() {
  key='n';
}

void drawSelect_start(){
  image(start,88,352,224,64);
  image(start,712,352,224,64);
}

void drawSelect_over(){
  image(retry,88,352,224,64);
  image(retry,712,352,224,64);
  image(home,88,432,224,64);
  image(home,712,432,224,64);
}

void drawJudge(int winner){
  int winX;
  int loseY;
  if(winner==1){
    winX=88;
    loseY=712;
  }else{//winner==2
    winX=712;
    loseY=88;
  }
  image(win,winX,544,224,64);
  image(lose,loseY,544,224,64);
  
}

void drawblocks() {
  //player1 blocks
  for (int i=0; i<7; i++) {
    for (int j=0; j<4; j++) {
      textSize(40);
      fill(255);
      if (player1._x==j&&player1._y==i) {
        //now
        drawblock_(72+64*j, 224+64*i, player1._now);
      } else {
        //stage
        drawblock_(72+64*j, 224+64*i, player1._stage[i][j]);
      }
    }
  }
  //hold
  drawblock_(432, 256, player1._hold);
  //next
  int number_count=0;
  int sign_count=0;
  int avoid_double=player1._sry;
  char next = player1._next_type;
  for (int i=0; i<5; i++) {
    if (next=='n' || avoid_double==0) {
      if (avoid_double==0) {
        avoid_double=10;
      }
      avoid_double-=1;
      drawblock_(432, 352+64*i, player1._number_set1[number_count]);
      number_count+=1;
      next='s';
    } else {
      drawblock_(432, 352+64*i, player1._sign_set1[sign_count]);
      sign_count+=1;
      next='n';
    }
  }
  //player2 blocks
  for (int i=0; i<7; i++) {
    for (int j=0; j<4; j++) {
      if (player2._x==j&&player2._y==i) {
        drawblock_(696+64*j, 224+64*i, player2._now);
      } else {
        drawblock_(696+64*j, 224+64*i, player2._stage[i][j]);
      }
    }
  }
  drawblock_(528, 256, player2._hold);
  //hold
  number_count=0;
  sign_count=0;
  avoid_double=player2._sry;
  next = player2._next_type;
  for (int i=0; i<5; i++) {
    if (next=='n' || avoid_double==0) {
      if (avoid_double==0) {
        avoid_double=10;
      }
      avoid_double-=1;
      drawblock_(528, 352+64*i, player2._number_set1[number_count]);
      number_count+=1;
      next='s';
    } else {
      drawblock_(528, 352+64*i, player2._sign_set1[sign_count]);
      sign_count+=1;
      next='n';
    }
  }
}

void drawblock_(int x, int y, String value) {
  if (value=="+") {
    image(plus, x, y, 64, 64);
  } else if (value=="-") {
    image(minus, x, y, 64, 64);
  } else if (value=="*") {
    image(multiply, x, y, 64, 64);
  } else if (value=="/") {
    image(divide, x, y, 64, 64);
  } else if (value!="0") {
    image(blocks_img[int(value)-1], x, y, 64, 64);
  }
}

void reset(boolean init){
  player1=new Player();
  player2=new Player();
  player1.setup();
  player2.setup();
  StartCount = 3;
  s_count=0;
  o_count=0;
  is_GameOver = false;
  keyPressed=false;
  key=' ';
  if(init){
    is_GameStarted = false;
  }
}
