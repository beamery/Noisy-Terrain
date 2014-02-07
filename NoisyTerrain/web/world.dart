part of noisyterrain;

class World {
  ShaderProgram defaultShader;
  Buffer triangleVxPosBuf;
  
  // World entities
  TerrainFragment terrain;
  Axis axis;
  LightSource light;
  
  World() {
    initGL();
    initEntities();
  }
  
  void initGL() {
    defaultShader = shaderManager['phong'];
    
    // Allocate and build the vertex buffer for our triangle
    triangleVxPosBuf = gl.createBuffer();
    
    gl.bindBuffer(ARRAY_BUFFER, triangleVxPosBuf);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([
        0.0,  1.0, 0.0, 0.0, 0.0, 1.0,
       -1.0, -1.0, 0.0, 0.0, 0.0, 1.0,
        1.0, -1.0, 0.0, 0.0, 0.0, 1.0
        ]), STATIC_DRAW);
  }
  
  void initEntities() {  
    // Create terrain with random height map
    initTerrain(200, 200);
    axis = new Axis();
    
    var lightProperties = new Material(
        new Vector3(0.1, 0.1, 0.1), 
        new Vector3(0.5, 0.5, 0.5), 
        new Vector3(0.7, 0.7, 0.7));
    light = new LightSource(lightProperties, new Vector4(40.0, 40.0, -100.0, 1.0));
  }
  
  /**
   * Initialize terrain with a random height map. Increment rows
   * and cols before creation because, in order to get an NxN grid,
   * we need (N+1)x(N+1) vertices.
   */
  void initTerrain(int rows, int cols) {
    rows++;
    cols++;
    
    Random rng = new Random();
    List<double> heightMap = new List<double>(rows * cols);
    for (int i = 0; i < heightMap.length; i++) {
      heightMap[i] =  rng.nextDouble();
      //heightMap[i] = 0.0;
    }
    terrain = new TerrainFragment(rows, cols, heightMap);
  }
  
  void drawWorld(time) {
    
    gl.useProgram(defaultShader.program);
    // Set up light position
    mvPush();
    Vector4 eyeLightPos = mv * light.position;
    mvPop();
    
    // Push lighting properties to the default shader
    gl.uniform4fv(defaultShader.uniforms['uLightPos'], eyeLightPos.storage);
    gl.uniform3fv(defaultShader.uniforms['uLa'], light.properties.ambient.storage);
    gl.uniform3fv(defaultShader.uniforms['uLd'], light.properties.diffuse.storage);
    gl.uniform3fv(defaultShader.uniforms['uLs'], light.properties.specular.storage);
    
    
    // Draw terrain
    mvPush();
    mv.translate(-(terrain.sizeX / 2.0), -1.0, -(terrain.sizeZ / 2.0));
    //mv.scale(0.2, 0.2, 0.2);
    terrain.draw(defaultShader);
    mvPop();
    
    // Draw axes
    mvPush();
    mv.scale(50.0, 50.0, 50.0);
    axis.draw();
    mvPop();
  }
}