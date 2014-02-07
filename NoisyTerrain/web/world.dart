part of noisyterrain;

class World {
  ShaderProgram defaultShader;
  Buffer triangleVxPosBuf;
  
  // World entities
  TerrainFragment terrain;
  Axis axis;
  
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

    mvPush();
    gl.useProgram(defaultShader.program);
    mv.translate(0.0, 0.0, 0.0);
    mv.rotateY((time / 1000) * PI / 2);
   
    // set up triangle buffer
    gl.bindBuffer(ARRAY_BUFFER, triangleVxPosBuf);
    gl.vertexAttribPointer(defaultShader.attributes['aPosition'], 3, FLOAT, false, 6 * 4, 0);
    gl.vertexAttribPointer(defaultShader.attributes['aNormal'], 3, FLOAT, false, 6 * 4, 3 * 4);
    
    // set matrix uniforms
    mvp = proj * mv;
    gl.uniformMatrix4fv(defaultShader.uniforms['uMVP'], false, mvp.storage); 
    gl.drawArrays(TRIANGLES, 0, 3);
    mvPop();
    
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