part of noisyterrain;

class World {
  final int TERRAIN_SIZE = 200;
  
  ShaderProgram defaultShader;
  Buffer triangleVxPosBuf;
  
  // World entities
  Player player;
  TerrainFragment terrain;
  Axis axis;
  LightSource light;
  
  // Getters
  num get sizeX => terrain.sizeX;
  num get sizeZ => terrain.sizeZ;
  
  World();
  
  void init() {
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
    
    // Initialize player
    player = new Player();
    
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
    Grid2D<double> heightMap = perlinNoise(size, 4, 15, 8, 0.3);
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
  
  void update(elapsedTime) {
    player.update(elapsedTime);
  }
  
  void draw(time) {
    
    gl.useProgram(defaultShader.program);
    
    mvPush();
    // Set up eye space to world space scale.
    mv.scale(5.0, 5.0, 5.0);
    
    // Apply player rotation.
    mv.rotateX(player.rotation.x);
    mv.rotateY(player.rotation.y);
    
    // Apply player translation.
    mv.translate(player.translation);
    
    // Set up light position.
    mvPush();
    Vector4 eyeLightPos = mv * light.position;
    mvPop();
    
    // Push lighting properties to the default shader.
    gl.uniform4fv(defaultShader.uniforms['uLightPos'], eyeLightPos.storage);
    gl.uniform3fv(defaultShader.uniforms['uLa'], light.properties.ambient.storage);
    gl.uniform3fv(defaultShader.uniforms['uLd'], light.properties.diffuse.storage);
    gl.uniform3fv(defaultShader.uniforms['uLs'], light.properties.specular.storage);
    
    
    // Draw terrain
    mvPush();

    //mv.translate(-(terrain.sizeX / 2.0), 0.0, -(terrain.sizeZ / 2.0));
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
  
  double getHeightAt(double x, double z) {
    int x0 = x.floor();
    int x1 = x.ceil();
    int z0 = z.floor();
    int z1 = z.ceil();
    
    // Get the heights for the four nearest grid points.
    double mag_x0z0 = terrain.heightMap[x0][z0];
    double mag_x0z1 = terrain.heightMap[x0][z1];
    double mag_x1z0 = terrain.heightMap[x1][z0];
    double mag_x1z1 = terrain.heightMap[x1][z1];
    
    // Interpolate in both the x and z directions to get the final output value.
    double outVal = interp2D(
        mag_x0z0, mag_x0z1, 
        mag_x1z0, mag_x1z1, 
        (x - x0), (z - z0), 'LINEAR');
    
    return outVal;
  }
  
  /**
   * Check to make sure that pos is in the bounds of the world.
   * Right now, just makes sure that x and z coordinates are ok.
   */
  bool isInWorldBounds(Vector3 pos) {
    return (pos.x >= 0 && pos.x <= (this.sizeX - 1) && 
        pos.z >= 0 && pos.z <= (this.sizeZ - 1));
  }
}