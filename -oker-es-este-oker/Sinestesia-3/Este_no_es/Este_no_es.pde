import oscP5.*;
import netP5.*;
import spout.*; 
import java.util.Arrays;

// ====================================================================
// CONFIGURACIÓN DE POSES (MODIFICA ESTOS NÚMEROS A TU GUSTO)
// Usa grados normales (0 a 360)
// ====================================================================

// --- CUBO 1 (Izquierda) ---
float CUBE1_ROT_X = 60;   // Inclinación hacia arriba/abajo
float CUBE1_ROT_Y = 30;   // Giro hacia los lados
float CUBE1_ROT_Z = 0;    // Inclinación lateral

// --- CUBO 2 (Centro) ---
float CUBE2_ROT_X = 90;   // Inclinación hacia arriba/abajo
float CUBE2_ROT_Y = 85;  // Giro hacia los lados
float CUBE2_ROT_Z = 0;  // Inclinación lateral

// --- CUBO 3 (Derecha) ---
float CUBE3_ROT_X = 120;  // Inclinación hacia arriba/abajo
float CUBE3_ROT_Y = 30;  // Giro hacia los lados
float CUBE3_ROT_Z = 0;  // Inclinación lateral 

// ====================================================================
// VARIABLES DEL SISTEMA
// ====================================================================
final float SPRING = 0.05f;
final float GRAVITY = 0.01f;
final float FRICTION = -0.9f;
final float LANDMARK_RADIUS = 150.0f;
final float CUBE_SIZE = 200.0f;
final int PARTICLES_PER_SYSTEM = 50;

final PVector CUBE_1_CENTER = new PVector(-400, 0, 0);
final PVector CUBE_2_CENTER = new PVector(0, 0, 0);
final PVector CUBE_3_CENTER = new PVector(400, 0, 0);

PShape shapeSphereOBJ;
PShape shapeCubeOBJ;
PShape shapePyramidOBJ;

ParticleSystem system1, system2, system3;
PVector[] poseLandmarks = new PVector[0];
PVector mouse3D = new PVector(0, 0, 0);

OscP5 oscP5;
NetAddress myRemoteLocation;
final int OSC_RECEIVE_PORT = 12000;
final int OSC_SEND_PORT = 12001;
Spout spout; 

void settings() {
  size(1280, 720, P3D); 
  PJOGL.profile = 1; 
}

void setup() {
  colorMode(HSB, 360, 100, 100, 100);
  
  shapeSphereOBJ  = loadShape("esfera2.obj");
  shapeCubeOBJ    = loadShape("esfera3.obj");
  shapePyramidOBJ = loadShape("esferaconpicos.obj");
  
  perspective();
  
  spout = new Spout(this);
  spout.createSender("Processing Static Cubes");

  /* system1 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_PYRAMID, CUBE_1_CENTER, CUBE_SIZE, this);
  system2 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_CUBE, CUBE_2_CENTER, CUBE_SIZE, this);
  system3 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_SPHERE, CUBE_3_CENTER, CUBE_SIZE, this);
  */
  
  // CUBO 1 (Pirámides) - Escala visual: 15 (se ven más pequeños)
  system1 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_PYRAMID, CUBE_1_CENTER, CUBE_SIZE, this, radians(CUBE1_ROT_X), radians(CUBE1_ROT_Y), radians(CUBE1_ROT_Z), 10);
  
  // CUBO 2 (Cubos) - Escala visual: 25 (tamaño medio)
  system2 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_CUBE, CUBE_2_CENTER, CUBE_SIZE, this, radians(CUBE2_ROT_X), radians(CUBE2_ROT_Y), radians(CUBE2_ROT_Z), 15);
  
  // CUBO 3 (Esferas) - Escala visual: 35 (se ven más grandes)
  system3 = new ParticleSystem(PARTICLES_PER_SYSTEM, Particle3D.SHAPE_SPHERE, CUBE_3_CENTER, CUBE_SIZE, this, radians(CUBE3_ROT_X), radians(CUBE3_ROT_Y), radians(CUBE3_ROT_Z), 15);
  // -----------------------------------------------------------------------------------------------------------------------------------------------------------------


  
  initOSCConnection();
}

void draw() {
  background(0); 

  translate(width / 2.0f, height / 2.0f, 0);
  translate(0, 0, -150); // Zoom general de la cámara

  ambientLight(0, 0, 150);
  directionalLight(255, 255, 255, 0.5f, 0.5f, -1);
  
  mouse3D.set(mouseX - width / 2.0f, mouseY - height / 2.0f, 0);

  stroke(255, 255, 255, 100);
  strokeWeight(2);
  noFill();

  // --- DIBUJAR CUBO 1 ---
  pushMatrix();
  translate(CUBE_1_CENTER.x, CUBE_1_CENTER.y, CUBE_1_CENTER.z);
  // Aquí aplicamos TUS ángulos convertidos a radianes
  rotateX(radians(CUBE1_ROT_X));
  rotateY(radians(CUBE1_ROT_Y));
  rotateZ(radians(CUBE1_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

  // --- DIBUJAR CUBO 2 ---
  pushMatrix();
  translate(CUBE_2_CENTER.x, CUBE_2_CENTER.y, CUBE_2_CENTER.z);
  rotateX(radians(CUBE2_ROT_X));
  rotateY(radians(CUBE2_ROT_Y));
  rotateZ(radians(CUBE2_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

  // --- DIBUJAR CUBO 3 ---
  pushMatrix();
  translate(CUBE_3_CENTER.x, CUBE_3_CENTER.y, CUBE_3_CENTER.z);
  rotateX(radians(CUBE3_ROT_X));
  rotateY(radians(CUBE3_ROT_Y));
  rotateZ(radians(CUBE3_ROT_Z));
  box(CUBE_SIZE);
  popMatrix();

  // Renderizado de partículas
  system1.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D);
  system2.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D);
  system3.run(poseLandmarks, LANDMARK_RADIUS, GRAVITY, FRICTION, mouse3D);
  
  system1.rotX = radians(CUBE1_ROT_X);
  system1.rotY = radians(CUBE1_ROT_Y);
  system1.rotZ = radians(CUBE1_ROT_Z);
  
  system2.rotX = radians(CUBE2_ROT_X);
  system2.rotY = radians(CUBE2_ROT_Y);
  system2.rotZ = radians(CUBE2_ROT_Z);
  
  system3.rotX = radians(CUBE3_ROT_X);
  system3.rotY = radians(CUBE3_ROT_Y);
  system3.rotZ = radians(CUBE3_ROT_Z);

  if (poseLandmarks.length > 0) drawLandmarks(poseLandmarks);
  if (frameCount % 3 == 0) sendParticleData();
  
  spout.sendTexture(); 
}

// (MANTÉN AQUÍ ABAJO LAS MISMAS FUNCIONES OSC DE SIEMPRE: initOSCConnection, etc.)
// Copia y pega las funciones auxiliares del código anterior.

// ... (El resto de tus funciones OSC se quedan igual)
// ... (initOSCConnection, oscEvent, updateLandmarks, sendParticleData, etc.)

// ====================================================================
// FUNCIONES OSC
// ====================================================================

void initOSCConnection() {
  try {
    oscP5 = new OscP5(this, OSC_RECEIVE_PORT);
    myRemoteLocation = new NetAddress("127.0.0.1", OSC_SEND_PORT);
    println("✓ OSC inicializado correctamente");
  }
  catch (Exception e) {
    println("✗ Error al inicializar OSC: " + e.getMessage());
  }
}

// Recibir mensajes OSC (sin cambios)
void oscEvent(OscMessage theOscMessage) {
  String address = theOscMessage.addrPattern();

  try {
    if (address.equals("/pose/landmarks") || address.equals("/hand/landmarks")) {
      // ... (lógica de landmarks)
    }

    if (address.equals("/simulation/reset")) {
      resetSimulation();
    }
  }
  catch (Exception e) {
    println("✗ Error procesando mensaje OSC: " + address);
    println("  " + e.getMessage());
  }
}

// Actualizar landmarks desde datos OSC (sin cambios)
void updateLandmarks(float val1, float val2) {
  poseLandmarks = new PVector[2];

  // Normalizar de rango [-1, 3] a [0, 1]
  float norm1 = (val1 + 1.0f) / 4.0f;
  float norm2 = (val2 + 1.0f) / 4.0f;

  // Mapear a espacio 3D (ajustado al rango de los 3 cubos)
  float x1 = map(norm1, 0, 1, -width/2, width/2);
  float y1 = 0;
  float z1 = 0;

  float x2 = map(norm2, 0, 1, -width/2, width/2);
  float y2 = 0;
  float z2 = 0;

  poseLandmarks[0] = new PVector(x1, y1, z1);
  poseLandmarks[1] = new PVector(x2, y2, z2);
}

// Enviar posiciones de partículas a TouchDesigner (Actualizado)
void sendParticleData() {
  if (oscP5 == null || myRemoteLocation == null) {
    return;
  }

  int particlesToSend = 15; // Ajusta cuántas posiciones enviar por sistema

  // Enviar datos para el Sistema 1: Pirámides
  // Dirección OSC clara para TD: /particles/pyramids/pos
  sendSystemPositions(system1.particles, "/particles/pyramids/pos", min(particlesToSend, system1.particles.length));

  // Enviar datos para el Sistema 2: Cubos
  // Dirección OSC clara para TD: /particles/cubes/pos
  sendSystemPositions(system2.particles, "/particles/cubes/pos", min(particlesToSend, system2.particles.length));

  // Enviar datos para el Sistema 3: Esferas
  // Dirección OSC clara para TD: /particles/spheres/pos
  sendSystemPositions(system3.particles, "/particles/spheres/pos", min(particlesToSend, system3.particles.length));

  // Enviar las posiciones de los cubos (para que TD sepa dónde están)
  sendContainerPositions();
}

// Nueva función de utilidad para enviar un conjunto de partículas
void sendSystemPositions(Particle3D[] particles, String address, int count) {
  OscMessage msg = new OscMessage(address);

  for (int i = 0; i < count; i++) {
    PVector pos = particles[i].getPosition();
    // Envía la posición global de cada partícula
    msg.add(pos.x);
    msg.add(pos.y);
    msg.add(pos.z);
  }

  oscP5.send(msg, myRemoteLocation);
}

// Nueva función para enviar las posiciones centrales de los contenedores
void sendContainerPositions() {
  OscMessage msg = new OscMessage("/containers/centers");
  msg.add(CUBE_SIZE); // Incluye el tamaño del cubo para que TD pueda recrearlo

  msg.add(CUBE_1_CENTER.x).add(CUBE_1_CENTER.y).add(CUBE_1_CENTER.z);
  msg.add(CUBE_2_CENTER.x).add(CUBE_2_CENTER.y).add(CUBE_2_CENTER.z);
  msg.add(CUBE_3_CENTER.x).add(CUBE_3_CENTER.y).add(CUBE_3_CENTER.z);

  oscP5.send(msg, myRemoteLocation);
}

// Resetear simulación (Actualizado)
void resetSimulation() {
  system1.reset();
  system2.reset();
  system3.reset();
  println("↻ Simulación reseteada");
}

// Dibujar landmarks (debug) (sin cambios)
void drawLandmarks(PVector[] landmarks) {
  pushMatrix();
  noStroke();

  for (int i = 0; i < landmarks.length; i++) {
    PVector lm = landmarks[i];

    pushMatrix();
    translate(lm.x, lm.y, lm.z);

    fill((i * 180) % 360, 80, 100, 80);
    sphere(25);

    popMatrix();
  }

  popMatrix();
}

// ====================================================================
// CONTROLES
// ====================================================================

void keyPressed() {
  if (key == 'r' || key == 'R') {
    resetSimulation();
  }

  if (key == 'd' || key == 'D') {
    println("═══════════════════════════════════");
    println("DEBUG INFO:");
    println("  Sistemas Activos: 3");
    println("  Partículas totales: " + (PARTICLES_PER_SYSTEM * 3));
    println("  FPS: " + round(frameRate));
    println("═══════════════════════════════════");
  }

  if (key == 'h' || key == 'H') {
    println("═══════════════════════════════════");
    println("CONTROLES:");
    println("  R - Resetear simulación");
    println("  D - Mostrar debug info");
    println("  H - Mostrar ayuda");
    println("═══════════════════════════════════");
  }
}
