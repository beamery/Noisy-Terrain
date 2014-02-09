part of noisyterrain;

class World {
  final int TERRAIN_SIZE = 200;
  
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
    initTerrain(TERRAIN_SIZE);
    axis = new Axis();
    
    var lightProperties = new Material(
        new Vector3(0.1, 0.1, 0.1), 
        new Vector3(0.9, 0.9, 0.9), 
        new Vector3(0.7, 0.7, 0.7));
    light = new LightSource(lightProperties, new Vector4(0.0, 50.0, -100.0, 1.0));
  }
  
  /**
   * Initialize terrain with a random height map. Increment rows
   * and cols before creation because, in order to get an NxN grid,
   * we need (N+1)x(N+1) vertices.
   */
  void initTerrain(int size) {
    size++;
    /*
    Random rng = new Random();
    Grid2D<double> heightMap = new Grid2D<double>(rows, cols);
    for (int i = 0; i < heightMap.rows; i++) {
      for (int j = 0; j < heightMap.cols; j++) {
        heightMap[i][j] =  rng.nextDouble();
        //heightMap[i][j] = 0.0; 
      }
    }
    */
    Grid2D<double> heightMap = perlinNoise(size, 4, 20, 8, 0.5);
    double min = 1000.0;
    double max = -1000.0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (heightMap[i][j] < min) {
          min = heightMap[i][j];
        }
        if (heightMap[i][j] > max) {
          max = heightMap[i][j];
        }
      }
    }
    print('min: $min');
    print('max: $max');
    
    terrain = new TerrainFragment(size, size, heightMap);
  }
  
  void drawWorld(time) {
    
    gl.useProgram(defaultShader.program);
    
    mvPush();
    // Set up eye space to world space scale
    mv.scale(5.0, 5.0, 5.0);
    
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

    mv.translate(-(terrain.sizeX / 2.0), 0.0, -(terrain.sizeZ / 2.0));
    terrain.draw(defaultShader);
    mvPop();
    
    // Draw axes
    mvPush();
    mv.translate(0.0, 1.0, 0.0);
    mv.scale(TERRAIN_SIZE.toDouble(), TERRAIN_SIZE.toDouble(), TERRAIN_SIZE.toDouble());
    axis.draw();
    mvPop();
    
    mvPop();
  }
}