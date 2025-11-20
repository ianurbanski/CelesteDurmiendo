import processing.core.*;



// Clase Particle3D
class Particle3D {
    // Tipos de forma (Nuevas constantes)
    final static int SHAPE_SPHERE = 0;
    final static int SHAPE_CUBE = 1;
    final static int SHAPE_PYRAMID = 2;

    // Variables de estado
    float x, y, z;
    float vx, vy, vz;
    float diameter;
    int id;
    float mass;
    int shapeType; // Almacena el tipo de forma
    
    //modelo3d
    PShape model3D;

    // Rotación
    float rotX, rotY, rotZ;
    float rotSpeedX, rotSpeedY, rotSpeedZ;

    // Color
    float hue; 

    // Límites del Contenedor (Nuevos campos)
    PVector containerCenter;
    float containerSize;
    float containerHalfSize;
    
    float containerRotX, containerRotY, containerRotZ;

    float visualScale;
    
    // Referencias
    PApplet p;
    Particle3D[] others;
    
    final float MOUSE_RADIUS = 150.0f; 

    // Constructor actualizado
    Particle3D(float xin, float yin, float zin, float din, int idin, Particle3D[] oin, PApplet parent, int sType, PVector center, float size, PShape model3D , float rotX, float rotY, float rotZ, float sFactor) {
        this.p = parent;
        this.x = xin;
        this.y = yin;
        this.z = zin;
        this.diameter = din;
        this.id = idin;
        this.others = oin;
        this.mass = din * 0.1f; 
        
        this.shapeType = sType; 
        
        // Asignar límites del contenedor
        this.containerCenter = center;
        this.containerSize = size;
        this.containerHalfSize = size / 2.0f;
        
        
        // **✓ CAMBIO 3: Asignar la rotación inicial del contenedor**
        this.containerRotX = rotX;
        this.containerRotY = rotY;
        this.containerRotZ = rotZ;
        
        // **✓ CAMBIO 6: Asignar la escala visual**
        this.visualScale = sFactor;
        
        // Inicialización de velocidad y rotación (igual que antes)
        this.vx = 0; this.vy = 0; this.vz = 0;
        this.rotX = parent.random(parent.TWO_PI);
        this.rotY = parent.random(parent.TWO_PI);
        this.rotZ = parent.random(parent.TWO_PI);
        this.rotSpeedX = parent.random(-0.03f, 0.03f);
        this.rotSpeedY = parent.random(-0.03f, 0.03f);
        this.rotSpeedZ = parent.random(-0.03f, 0.03f);
        this.hue = parent.random(360);
        
        this.model3D = model3D;
    }
    
    // Colisión con landmarks (sin cambios)
    void collideWithPose(PVector[] landmarks, float landmarkRadius) { 
        for (PVector landmark : landmarks) {
            float landmarkX = landmark.x;
            float landmarkY = landmark.y;
            float landmarkZ = landmark.z;

            float dx = landmarkX - this.x;
            float dy = landmarkY - this.y;
            float dz = landmarkZ - this.z;
            float distance = PApplet.sqrt(dx * dx + dy * dy + dz * dz);

            float minDist = landmarkRadius / 2 + this.diameter / 2;

            if (distance < minDist) {
                float factor = (minDist - distance) * 0.2f;

                if (distance > 0) {
                    float nx = dx / distance;
                    float ny = dy / distance;
                    float nz = dz / distance;

                    this.vx -= nx * factor;
                    this.vy -= ny * factor;
                    this.vz -= nz * factor;

                    this.x -= nx * (minDist - distance) * 0.5f;
                    this.y -= ny * (minDist - distance) * 0.5f;
                    this.z -= nz * (minDist - distance) * 0.5f;
                }
            }
        }
    }

    // Colisión con mouse (sin cambios)
    void collideWithMouse(PVector mousePos) {
        final float REPULSION_FACTOR = 0.2f;
        
        float mouseX = mousePos.x;
        float mouseY = mousePos.y;

        float dx = mouseX - this.x;
        float dy = mouseY - this.y;
        float distance = PApplet.sqrt(dx * dx + dy * dy);
        
        float minDist = MOUSE_RADIUS / 2 + this.diameter / 2;

        if (distance < minDist && distance > 0) {
            float factor = (minDist - distance) * REPULSION_FACTOR; 

            float nx = dx / distance;
            float ny = dy / distance;

            this.vx -= nx * factor;
            this.vy -= ny * factor;

            this.x -= nx * (minDist - distance) * 0.5f;
            this.y -= ny * (minDist - distance) * 0.5f;
        }
    }

    // Colisión entre partículas (sin cambios, usa 'others')
    void collide(float spring, int numParticles) { 
        for (int i = this.id + 1; i < numParticles; i++) {
            if (others[i] == null) continue;
            
            float dx = others[i].x - this.x;
            float dy = others[i].y - this.y;
            float dz = others[i].z - this.z;
            float distance = PApplet.sqrt(dx * dx + dy * dy + dz * dz);
            float minDist = others[i].diameter / 2 + this.diameter / 2;

            if (distance < minDist && distance > 0) {
                float factor = (minDist - distance) * spring;
                float nx = dx / distance;
                float ny = dy / distance;
                float nz = dz / distance;

                this.vx -= nx * factor;
                this.vy -= ny * factor;
                this.vz -= nz * factor;
                others[i].vx += nx * factor;
                others[i].vy += ny * factor;
                others[i].vz += nz * factor;
            }
        }
    }
    
    // Movimiento y física actualizado para usar los límites del contenedor
  /*  void move(PApplet p, float gravity, float friction) {
        final float THRESHOLD = 0.01f; 
        
        // 1. APLICAR GRAVEDAD
        this.vy += gravity;

        // 2. APLICAR VELOCIDAD
        this.x += this.vx;
        this.y += this.vy;
        this.z += this.vz;

        // 3. COLISIÓN CON LÍMITES DEL CONTENEDOR ESPECÍFICO
        float margin = this.diameter / 2.0f;
        
        // Límites X
        float minX = containerCenter.x - containerHalfSize;
        float maxX = containerCenter.x + containerHalfSize;
        if (this.x > maxX - margin) {
            this.x = maxX - margin;
            this.vx *= friction; 
            if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0; 
        } else if (this.x < minX + margin) {
            this.x = minX + margin;
            this.vx *= friction; 
            if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0; 
        }

        // Límites Y
        float minY = containerCenter.y - containerHalfSize;
        float maxY = containerCenter.y + containerHalfSize;
        if (this.y > maxY - margin) {
            this.y = maxY - margin;
            this.vy *= friction; 
            if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0; 
        } else if (this.y < minY + margin) {
            this.y = minY + margin;
            this.vy *= friction; 
            if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0; 
        }

        // Límites Z
        float minZ = containerCenter.z - containerHalfSize;
        float maxZ = containerCenter.z + containerHalfSize;
        if (this.z > maxZ - margin) {
            this.z = maxZ - margin;
            this.vz *= friction; 
            if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0; 
        } else if (this.z < minZ + margin) {
            this.z = minZ + margin;
            this.vz *= friction; 
            if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0; 
        }
        
        // 4. ACTUALIZAR ROTACIÓN
        this.rotX += this.rotSpeedX;
        this.rotY += this.rotSpeedY;
        this.rotZ += this.rotSpeedZ;
    } */
    
    
    void move(PApplet p, float gravity, float friction) {
        final float THRESHOLD = 0.01f; 
        
        // 1. APLICAR GRAVEDAD y VELOCIDAD (en espacio GLOBAL)
        this.vy += gravity;
        this.x += this.vx;
        this.y += this.vy;
        this.z += this.vz;

        // 2. Coordenadas relativas al centro del cubo (espacio global)
        float rx = this.x - containerCenter.x;
        float ry = this.y - containerCenter.y;
        float rz = this.z - containerCenter.z;
        
        // 3. TRANSFORMAR AL ESPACIO LOCAL DEL CUBO (Rotación Inversa)
        // Aplicamos la rotación inversa para que el cubo no rotado sea el límite.
        
        float temp_x, temp_y, temp_z;
        
        // Rotación inversa Z
        temp_x = rx * PApplet.cos(-containerRotZ) - ry * PApplet.sin(-containerRotZ);
        temp_y = rx * PApplet.sin(-containerRotZ) + ry * PApplet.cos(-containerRotZ);
        rx = temp_x;
        ry = temp_y;
        
        // Rotación inversa Y
        temp_x = rx * PApplet.cos(-containerRotY) + rz * PApplet.sin(-containerRotY);
        temp_z = -rx * PApplet.sin(-containerRotY) + rz * PApplet.cos(-containerRotY);
        rx = temp_x;
        rz = temp_z;

        // Rotación inversa X
        temp_y = ry * PApplet.cos(-containerRotX) - rz * PApplet.sin(-containerRotX);
        temp_z = ry * PApplet.sin(-containerRotX) + rz * PApplet.cos(-containerRotX);
        ry = temp_y;
        rz = temp_z;
        
        // 4. VERIFICAR COLISIÓN EN ESPACIO LOCAL (Caja No Rotada)
        float margin = this.diameter / 2.0f;
        float maxLocal = containerHalfSize - margin;

        // Colisión X
        if (rx > maxLocal) {
            rx = maxLocal;
            this.vx *= friction;
            if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0; 
        } else if (rx < -maxLocal) {
            rx = -maxLocal;
            this.vx *= friction;
            if (PApplet.abs(this.vx) < THRESHOLD) this.vx = 0; 
        }

        // Colisión Y
        if (ry > maxLocal) {
            ry = maxLocal;
            this.vy *= friction;
            if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0; 
        } else if (ry < -maxLocal) {
            ry = -maxLocal;
            this.vy *= friction;
            if (PApplet.abs(this.vy) < THRESHOLD) this.vy = 0; 
        }

        // Colisión Z
        if (rz > maxLocal) {
            rz = maxLocal;
            this.vz *= friction; 
            if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0; 
        } else if (rz < -maxLocal) {
            rz = -maxLocal;
            this.vz *= friction; 
            if (PApplet.abs(this.vz) < THRESHOLD) this.vz = 0; 
        }
        
        // 5. TRANSFORMAR POSICIÓN DE VUELTA AL ESPACIO GLOBAL (Rotación Normal)

        // Rotación normal X
        temp_y = ry * PApplet.cos(containerRotX) - rz * PApplet.sin(containerRotX);
        temp_z = ry * PApplet.sin(containerRotX) + rz * PApplet.cos(containerRotX);
        ry = temp_y;
        rz = temp_z;
        
        // Rotación normal Y
        temp_x = rx * PApplet.cos(containerRotY) + rz * PApplet.sin(containerRotY);
        temp_z = -rx * PApplet.sin(containerRotY) + rz * PApplet.cos(containerRotY);
        rx = temp_x;
        rz = temp_z;

        // Rotación normal Z
        temp_x = rx * PApplet.cos(containerRotZ) - ry * PApplet.sin(containerRotZ);
        temp_y = rx * PApplet.sin(containerRotZ) + ry * PApplet.cos(containerRotZ);
        rx = temp_x;
        ry = temp_y;
        
        // 6. ASIGNAR POSICIÓN FINAL GLOBAL
        this.x = rx + containerCenter.x;
        this.y = ry + containerCenter.y;
        this.z = rz + containerCenter.z;
        
        // 7. ACTUALIZAR ROTACIÓN DE LA PARTÍCULA
        this.rotX += this.rotSpeedX;
        this.rotY += this.rotSpeedY;
        this.rotZ += this.rotSpeedZ;
    }

    // Renderizar en 3D
    void display() { 
        p.pushMatrix(); 
        p.translate(this.x, this.y, this.z);
    
        // Rotación de la partícula
        p.rotateX(this.rotX);
        p.rotateY(this.rotY);
        p.rotateZ(this.rotZ);
    
        // Color dinámico
        float speed = PApplet.sqrt(this.vx*this.vx + this.vy*this.vy + this.vz*this.vz);
        float brightness = PApplet.map(speed, 0, 15, 40, 100);
        float saturation = PApplet.map(speed, 0, 15, 60, 100);
        float depthAlpha = PApplet.map(this.z,
            containerCenter.z - containerHalfSize,
            containerCenter.z + containerHalfSize,
            100, 40);
    
        p.fill(this.hue, saturation, brightness, depthAlpha);
        p.noStroke();
    
        // Escala final del modelo
        float scaleFactor = this.diameter;
    
        if (model3D != null) {
            // **✓ CAMBIO 7: Usar la nueva escala visual del sistema**
            p.scale(this.visualScale); 
            // ------------------------------------------------------
            p.shape(model3D);
        }
    
        p.popMatrix(); 
    } 


    // Función para dibujar una pirámide simple con base cuadrada
    void drawPyramid(float size) {
        float h = size; 
        float s = size; 
        
        p.beginShape(PApplet.TRIANGLES);
        
        // Cara 1
        p.vertex(0, -h/2, 0); p.vertex( s/2, h/2, -s/2); p.vertex(-s/2, h/2, -s/2); 

        // Cara 2
        p.vertex(0, -h/2, 0); p.vertex(-s/2, h/2, -s/2); p.vertex(-s/2, h/2, s/2);

        // Cara 3
        p.vertex(0, -h/2, 0); p.vertex(-s/2, h/2, s/2); p.vertex(s/2, h/2, s/2);
        
        // Cara 4
        p.vertex(0, -h/2, 0); p.vertex(s/2, h/2, s/2); p.vertex(s/2, h/2, -s/2);
        
        p.endShape();
    }
    
    PVector getPosition() {
        return new PVector(this.x, this.y, this.z);
    }
}
