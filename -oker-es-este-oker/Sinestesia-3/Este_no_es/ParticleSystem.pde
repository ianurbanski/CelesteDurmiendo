import processing.core.*;

// Clase que gestiona un grupo de partículas y su contenedor específico.
class ParticleSystem {
    PApplet p;
    Particle3D[] particles;
    PVector containerCenter;
    float containerSize;
    int particleShape;
    
    float rotX, rotY, rotZ;
    
    float shapeScaleFactor;
    
    float particleModelScale = 25;
     
     
    /* ParticleSystem(int numParticles, int shapeType, PVector center, float size, PApplet parent) {
        this.p = parent;
        this.containerCenter = center;
        this.containerSize = size;
        this.particleShape = shapeType;
        this.particles = new Particle3D[numParticles];
        
        
        this.rotX = 0;
        this.rotY = 0;
      this.rotZ = 0;

        initializeParticles(numParticles); */
        
        ParticleSystem(int numParticles, int shapeType, PVector center, float size, PApplet parent, float rx, float ry, float rz, float sFactor) {
        this.p = parent;
        this.containerCenter = center;
        this.containerSize = size;
        this.particleShape = shapeType;
        this.particles = new Particle3D[numParticles];
        
        this.rotX = rx; // Usar los ángulos pasados
        this.rotY = ry;
        this.rotZ = rz;
        
        this.shapeScaleFactor = sFactor;
        
        initializeParticles(numParticles);
    }
    
    // Inicializa las partículas dentro de los límites del cubo asignado
    void initializeParticles(int numParticles) {
        float halfSize = containerSize / 2.0f;
        
        for (int i = 0; i < numParticles; i++) {
            // Posición inicial aleatoria dentro de los límites del cubo
            float startX = containerCenter.x + p.random(-halfSize, halfSize);
            float startY = containerCenter.y + p.random(-halfSize, halfSize);
            float startZ = containerCenter.z + p.random(-halfSize, halfSize);
            
            // Crea una nueva partícula con sus límites específicos
           PShape model;

          if (particleShape == Particle3D.SHAPE_SPHERE)  model = shapeSphereOBJ;
          else if (particleShape == Particle3D.SHAPE_CUBE) model = shapeCubeOBJ;
          else model = shapePyramidOBJ;
          
          this.particles[i] = new Particle3D(
              startX, startY, startZ,
              p.random(15, 30), // El diámetro (15-30) define la colisión
              i,
              this.particles,
              p,
              this.particleShape,
              this.containerCenter,
              this.containerSize,
              model,
              this.rotX, this.rotY, this.rotZ,
              this.shapeScaleFactor // **✓ CAMBIO 3: Pasar el factor de escala visual**
          );
        }
    }

    // Ejecuta la simulación y el renderizado para todo el sistema
// ====================================================================
// ARCHIVO: ParticleSystem.pde
// ====================================================================

// ... (inicio de la clase)

// Ejecuta la simulación y el renderizado para todo el sistema
    void run(PVector[] poseLandmarks, float landmarkRadius, float gravity, float friction, PVector mouse3D) {
        for (Particle3D particle : particles) {
            
            // **✓ CAMBIO 1: Sincronizar la rotación del contenedor con la partícula**
            // Esto le dice a la partícula cómo está rotado su cubo padre
            particle.containerRotX = this.rotX; 
            particle.containerRotY = this.rotY;
            particle.containerRotZ = this.rotZ;
            // -----------------------------------------------------------------------
            
            // Colisiones que afectan a la partícula
            if (poseLandmarks.length > 0) {
                particle.collideWithPose(poseLandmarks, landmarkRadius);
            }
            particle.collide(SPRING, particles.length); 
            particle.collideWithMouse(mouse3D);
            
            // Física, movimiento y colisión con el contenedor asignado
            particle.move(p, gravity, friction); 
            
            // Renderizar
            particle.display();
        }
    }

// ... (resto de la clase)
    
    // Reinicia las posiciones de las partículas dentro de su contenedor
    void reset() {
        float halfSize = containerSize / 2.0f;
        
        for (Particle3D particle : particles) {
            particle.x = containerCenter.x + p.random(-halfSize, halfSize);
            particle.y = containerCenter.y + p.random(-halfSize, halfSize);
            particle.z = containerCenter.z + p.random(-halfSize, halfSize);
            
            // Reiniciar velocidades
            particle.vx = 0;
            particle.vy = 0;
            particle.vz = 0;
        }
    }
}
