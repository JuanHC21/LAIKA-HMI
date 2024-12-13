import processing.serial.*;
import grafica.*; 
import peasy.*;
import processing.core.PShape;

Serial myPort; // Objeto Serial

//--------------------------------------------------------------//Objeto 3D
PShape rocket; // Objeto para almacenar el modelo
float roll = 0; // Rotación alrededor del eje X
float pitch = 0; // Rotación alrededor del eje Y
float yaw = 0; // Rotación alrededor del eje Z
String inputData; // Variable para almacenar datos de entrada
//---------------------------------------------------------------//Velocimetro
float accelZ = 0;        // Aceleración en Z (dato recibido directamente)

// Configuración del rango de la gráfica
float minVal = 0;  // Valor mínimo del velocímetro
float maxVal = 30;   // Valor máximo del velocímetro
//---------------------------------------------------------------//Termometro
float temperatura = 0; // Valor inicial de la temperatura
float tempMin = 0;
float tempMax = 40;

float posX = 550; // Posición inicial en X del termómetro
float posY = 396;  // Posición inicial en Y del termómetro
float termometroAncho = 25; // Ancho del termómetro
float termometroAlto = 250; // Alto del termómetro
//---------------------------------------------------------------// Graf Giroscopio
GPlot plot;
GPointsArray puntosRoll, puntosPitch, puntosYaw; // Para almacenar los puntos de cada trayectoria
int maxPoints = 300; // Número máximo de puntos a mostrar en los gráficos
int currentIndex = 0; // Índice para el tiempo
int delayCount = 0; // Contador para reducir la frecuencia de muestreo
int updateRate = 5; // Cambia este valor para ajustar la frecuencia de actualización (más alto = más lento)
//---------------------------------------------------------------//Graf Altitude
GPlot plotAltitude;  // Gráfica de altitud
ArrayList<Float> timeAltitudeData;  // Lista de tiempo para altitud
ArrayList<Float> altitudeData;  // Lista de datos de altitud
float currentTime = 0;
float altitude = 0;
float maxAltitude = 60;  // Altitud máxima esperada
boolean isAltitudePaused = false;  // Control de pausa para altitud

//Declararacion de img
PImage icono1;
PImage icono2;
PImage icono3;
PImage icono4;
 
void setup() {
  size(1370, 740, P3D);//ventana 3D
  background(25);
  smooth();
  frameRate(60);
  
  // Cargar la imagen que está en la carpeta "data"
  icono1 = loadImage("rocket.png");
  icono2 = loadImage("line-chart.png");
  icono3 = loadImage("antena.png");
  icono4 = loadImage("logo.png");
  
  //--------------------------------------------- Cargar el modelo 3D
  rocket = loadShape("Rocket1.obj");
  if (rocket == null) {
    println("Error: modelo no cargado. Verifica el nombre y la ubicación del archivo.");
  }
  //----------------------------------------------Grafica altitud
    // Inicializar listas para almacenar los datos de tiempo y altitud
  timeAltitudeData = new ArrayList<Float>();
  altitudeData = new ArrayList<Float>();
  // Crear la gráfica de altitud
  plotAltitude = new GPlot(this);
  plotAltitude.setPos(750, 70);
  plotAltitude.setOuterDim(270, 270);
  plotAltitude.setTitleText("Curva de Altitud del Cohete");
  plotAltitude.getXAxis().setAxisLabelText("Tiempo (s)");
  plotAltitude.getYAxis().setAxisLabelText("Altitud (m)");
  plotAltitude.setYLim(0, maxAltitude);  // Ajustar el rango de la altitud
  //----------------------------------------------Grafica del giroscopio
  // Inicializa los puntos para las trayectorias
  puntosRoll = new GPointsArray();
  puntosPitch = new GPointsArray();
  puntosYaw = new GPointsArray();

   // Crea un nuevo gráfico para Roll, Pitch y Yaw juntos
  plot = new GPlot(this);
  plot.setPos(350, 70);
  plot.setOuterDim(380,270);
  plot.getTitle().setText("Trayectorias Roll, Pitch y Yaw");
  plot.getXAxis().setAxisLabelText("Tiempo");
  plot.getYAxis().setAxisLabelText("Grados");

  // Ajustar cuadrícula
  plot.setGridLineWidth(0.5);  // Grosor de las líneas de la cuadrícula
  plot.setGridLineColor(color(200));  // Color gris claro para las líneas de la cuadrícula

  // Ajustar los puntos
  plot.setPoints(puntosRoll);  // Iniciar con los puntos de Roll, pero se actualizarán
  plot.setYLim(-360, 360);  // Límites del eje Y para ángulos entre -180° y 180°
  
//-------------------------------------------------- // Lista de puertos seriales disponibles
  printArray(Serial.list());

  // Abre el puerto serial (ajusta el puerto según el listado que te muestra el monitor)
  myPort = new Serial(this, Serial.list()[6], 115200);
  myPort.bufferUntil('\n'); // Lee datos hasta encontrar un salto de línea
}
void draw() {
  background(50);
  noStroke();
  fill(70);
  rect(20, 20, 310, 330);/////////Cuadrado 1///PANEL 1
  fill(130);
  rect(20, 20, 310, 35);/////////Cuadrado 2///
  fill(70);
  rect(340, 20, 700, 330);/////////Cuadrado 3///PANEL 2
  fill(130);
  rect(340, 20, 700, 35);/////////Cuadrado 4///
  fill(70);
  rect(1050, 20, 310, 700);////////Cuadrado 5///PANEL 3
  fill(130);
  rect(1060, 30, 290, 680);////////Cuadrado 6///
  fill(70);
  rect(20, 360, 350, 300);/////////Cuadrado 7///PANEL 4///Bajo
  fill(130);
  rect(20, 360, 310, 35);//////////Cuadrado 8///
  fill(70);
  rect(340, 360, 340, 300);////////Cuadrado 9///PANEL 5
  fill(70);
  rect(690, 360, 350, 300);////////Cuadrado 10//PANEL 6
  rect(20, 670, 1020, 50);/////////Caudrado 11//PANEL 7
  
  
  ////////////////////////////////////////////////////////////LINEAS
  // Dibujar una línea vertical para separar el panel 2
  stroke(100);  //Color
  strokeWeight(1.5);  // Grosor 
  line(740, 90, 740, 310);  // Línea(punto a punto) desde (690, 20) hasta (690, 350)


  // Imagenes Cargadas 
  image(icono1,290, 25, 35, 35);  // Dibuja el ícono a partir de (50, 50), con tamaño 100x100
  image(icono2,290,360,35,35);
  image(icono3,700,380,100,100);
  image(icono4,860,-40,500,250);
  
  
  ////////////////////////////////////////////////////////////////Texto
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("LAIKA",1200, 60);
  textSize(32);
  text("AEROSPACE",1240,90);
  
  textSize(25);
  text("Velocimetro",100,375);
  textSize(25);
  text("POSICIÓN",80,35);
  textSize(25);
  text("Grafica ",400,35);
  textSize(25);
  text("Trayectoria del Satélite",820,35);
  
  ////////////////////////////////////////////////////////////////Graf Altitud
   // Dibujar el botón de pausa/reanudar para altitud
  fill(isAltitudePaused ? color(0, 255, 0) : color(255, 0, 0));  // Cambia el color según el estado
  rect(1150, 190, 100, 40);
  fill(0);
  text(isAltitudePaused ? "Reanudar" : "Pausar", 1200, 210);

  // Crear una matriz de puntos para graficar altitud
  GPointsArray pointsAltitude = new GPointsArray(timeAltitudeData.size());
  for (int i = 0; i < timeAltitudeData.size(); i++) {
    pointsAltitude.add(timeAltitudeData.get(i), altitudeData.get(i));
  }
  plotAltitude.setPoints(pointsAltitude);
  plotAltitude.defaultDraw();

  if (!isAltitudePaused) {
    // Agregar los datos de altitud recibidos a las listas
    timeAltitudeData.add(currentTime);
    altitudeData.add(altitude);
  }

  // Actualizar el tiempo
  currentTime += 0.1;
  
  ////////////////////////////////////////////////////////////////Termometro
  fill(200);
  rect(posX, posY, termometroAncho, termometroAlto); // Base del termómetro
  
  // Dibujar el nivel de temperatura
  float tempAltura = map(temperatura, tempMin, tempMax, 0, termometroAlto);
  color tempColor = color(map(temperatura, tempMin, tempMax, 0, 255), 0, map(temperatura, tempMin, tempMax, 255, 0));
  fill(tempColor); // Cambia el color según el valor de temperatura
  rect(posX, posY + termometroAlto - tempAltura, termometroAncho, tempAltura);
  
  // Dibujar escala de temperatura
  drawScale();
  
  //Mostrar nivel de temperatura 
  fill(255);
  textSize(18);
  textAlign(CENTER);
  text("Temp: " + nf(temperatura, 1, 1) + "°C", posX + termometroAncho / 2, posY - 20); // Muestra la temperatura con un decimal


  ////////////////////////////////////////////////////////////////Modelo 3D
  // Integración de la gráfica 3D en el panel dos
  pushMatrix();
  translate(225, 225, 100); // Panel 1
  scale(3.2); // Ajusta la escala del modelo
  
   // Rotación del modelo según los datos del giroscopio
  rotateX(-HALF_PI);
  rotateX(radians(pitch));
  rotateZ(radians(yaw));
  rotateY(radians(roll));
  
  
  shape(rocket); // Dibuja el modelo 3D
  popMatrix(); // Cierra el pushMatrix() correspondiente para evitar el error
  
   // Mostrar las lecturas de los ejes en el HMI
  //fill(255);
  textSize(22);
  fill(255,0,0);
  text("Roll: " + roll, 260, 260);
  fill(0,255,0);
  text("Pitch: " + pitch, 260, 285);
  fill(0,0,255);
  text("Yaw: " + yaw, 255, 310);
  
  ////////////////////////////////////////////////////////////////////Grafica giros
  // Actualizar el gráfico con los nuevos datos de Roll, Pitch y Yaw
  plot.setPoints(puntosRoll);  // Establecer los puntos de Roll
  plot.beginDraw();
  plot.drawBackground();
  plot.drawBox();
   // Dibujar la cuadrícula
  plot.drawGridLines(GPlot.BOTH);  // Cuadrícula tanto en el eje X como en el eje Y

  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.setLineColor(color(255, 0, 0)); // Rojo para Roll
  plot.drawLines();  // Dibujar la línea de Roll
  
  // Dibujar Pitch
  plot.setPoints(puntosPitch);
  plot.setLineColor(color(0, 255, 0)); // Verde para Pitch
  plot.drawLines();  // Dibujar la línea de Pitch

  // Dibujar Yaw
  plot.setPoints(puntosYaw);
  plot.setLineColor(color(0, 0, 255)); // Azul para Yaw
  plot.drawLines();  // Dibujar la línea de Yaw

  plot.endDraw(); 
  
  // Dibujar el velocímetro
  drawVelocimeter();
}

//---------------------------------------------------//Termometro nivel
void drawScale() {
  int numTicks = 8; // Número de líneas de la escala
  float tickSpacing = termometroAlto / (numTicks - 1); // Espaciado entre líneas
  textSize(14);
  fill(255);
  
  for (int i = 0; i < numTicks; i++) {
    float y = posY + termometroAlto - i * tickSpacing;
    line(posX - 8, y, posX, y); // Dibujar línea de escala
    
    // Mostrar valor de temperatura en cada línea de la escala
    int tickTemp = int(map(i, 0, numTicks - 1, tempMin, tempMax));
    textAlign(RIGHT, CENTER);
    text(tickTemp + "°C", posX - 10, y);
  }
}
//---------------------------------------------------//Velocimetro 
void drawVelocimeter() {
  translate(240, 610); // Centrar el velocímetro más abajo

  // Dibujar el arco del velocímetro (180 grados)
  stroke(0);
  strokeWeight(3);
  noFill();
  arc(0, 0, 300, 300, PI, TWO_PI); // Arco completo de 0 a 180 grados

  // Divisiones del velocímetro
  int numTicks = 20; // Número de divisiones
  for (int i = 0; i <= numTicks; i++) {
    float angle = map(i, 0, numTicks, PI, TWO_PI); // Divisiones a lo largo de 180 grados
    float x1 = cos(angle) * 130;
    float y1 = sin(angle) * 130;
    float x2 = cos(angle) * 150;
    float y2 = sin(angle) * 150;

    line(x1, y1, x2, y2);

    // Etiquetas numéricas
    if (i % 2 == 0) { // Mostrar etiquetas en divisiones pares
      float labelVal = map(i, 0, numTicks, minVal, maxVal);
      float xLabel = cos(angle) * 170;
      float yLabel = sin(angle) * 170;
      fill(0);
      noStroke();
      textAlign(CENTER, CENTER);
      text(nf(labelVal, 1, 1), xLabel, yLabel); // Mostrar etiquetas con 1 decimal
    }
  }

  // Dibujar la aguja del velocímetro
  float needleAngle = map(accelZ, minVal, maxVal, PI, TWO_PI);
  float needleX = cos(needleAngle) * 125;
  float needleY = sin(needleAngle) * 125;

  stroke(255, 0, 0); // Color rojo para la aguja
  strokeWeight(4);
  line(0, 0, needleX, needleY);

  // Centro del velocímetro
  fill(0);
  noStroke();
  ellipse(0, 0, 20, 20);

  // Mostrar el valor actual
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(nf(accelZ, 1, 2) + " m/s²", 0, -30); // Valor en el centro
}

////////////////////////////////////////////////////////////////////Entrada serial CVS

// Recepción de datos seriales
void serialEvent(Serial myPort) {
  inputData = myPort.readStringUntil('\n');
  if (inputData != null) {
    inputData = trim(inputData);
    String[] values = split(inputData, ',');
    if (values.length == 6) {
      roll = int(values[0]);
      pitch = int(values[1]);
      yaw = int(values[2]);
      temperatura = int(values[3]); 
      temperatura = constrain(temperatura, tempMin, tempMax); // Limita el valor dentro del rango
      altitude = float(values[4]);
      accelZ = float(values[5]); // Asignar directamente el valor del eje Z
      
      // Agrega los puntos a las respectivas trayectorias
      puntosRoll.add(currentIndex, roll);
      puntosPitch.add(currentIndex, pitch);
      puntosYaw.add(currentIndex, yaw);
      currentIndex++; // Incrementar el índice de tiempo

      // Limitar la cantidad de puntos en el gráfico
      if (puntosRoll.getNPoints() > maxPoints) {
        puntosRoll.remove(0);  // Eliminar el primer punto para mantener el límite
      }
      if (puntosPitch.getNPoints() > maxPoints) {
        puntosPitch.remove(0);
      }
      if (puntosYaw.getNPoints() > maxPoints) {
        puntosYaw.remove(0);
      }
    }
  }
}
void mousePressed() {
  // Verificar si el botón de pausa para altitud ha sido presionado
  if (mouseX > width - 140 && mouseX < width - 60 && mouseY > 30 && mouseY < 70) {
    isAltitudePaused = !isAltitudePaused;  // Cambiar el estado de pausa/reanudar para altitud
  }
}

void keyPressed() {
  int step = 10; // Tamaño del paso para mover el termómetro
  if (keyCode == LEFT) posX -= step;
  if (keyCode == RIGHT) posX += step;
  if (keyCode == UP) posY -= step;
  if (keyCode == DOWN) posY += step;
}
///////////////////////////////////////////////////////////
