part of noisyterrain;

class Mesh {
  Float32List vertexData;
  Buffer glVertexBuffer, glIndexBuffer;
  List<int> indices;
  int rows, cols;
  
  Mesh(List<Vertex> vertices, int rows, int cols) {
    this.indices = [];
    this.rows = rows;
    this.cols = cols;
    
    createIndexArray(vertices, rows, cols);
    getNormals(vertices, rows, cols);
    flattenVertices(vertices);
    glSetup();
  }
  
  /**
   * Create an index array which specifies the drawing order of our vertices.
   * We will draw all of our triangles clockwise for consistency.
   */
  void createIndexArray(List<Vertex> vertices, int rows, int cols) {
    for (int i = 0; i < rows - 1; i++) {
      for (int j = 0; j < cols - 1; j++) {     
        // Top-left triangle
        indices.add(getIndex(i, j));
        indices.add(getIndex(i, j+1));
        indices.add(getIndex(i+1, j));
        
        // bottom-right triangle
        indices.add(getIndex(i+1, j));
        indices.add(getIndex(i, j+1));
        indices.add(getIndex(i+1, j+1));
      }
    }
  }
  
  /**
   * Get the normals for each vertex and store them in the vertices.
   */
  void getNormals(List<Vertex> vertices, int rows, int cols) {    
    // Initialize the normal lists. 
    List<List<Vector3>> perVertexNormals = new List<List<Vector3>>(rows * cols);
    for (int i = 0; i < perVertexNormals.length; i++) {
      perVertexNormals[i] = new List<Vector3>();
    }
    
    for (int i = 0; i < rows - 1; i++) {
      for (int j = 0; j < cols - 1; j++) {
        // Top-left triangle
        Vector3 normalizedNorm = getNormFromTriangle(
            vertices[getIndex(i, j)].position,
            vertices[getIndex(i, j+1)].position,
            vertices[getIndex(i+1, j)].position);
        if ((normalizedNorm.length - 1).abs() > 0.0001) {
          print('ERROR: Length of normal does not equal 1.0');
        }
        perVertexNormals[getIndex(i, j)].add(normalizedNorm.clone());
        perVertexNormals[getIndex(i, j+1)].add(normalizedNorm.clone());
        perVertexNormals[getIndex(i+1, j)].add(normalizedNorm.clone());
        
        // Bottom-right triangle
        normalizedNorm = getNormFromTriangle(
            vertices[getIndex(i+1, j)].position,
            vertices[getIndex(i, j+1)].position,
            vertices[getIndex(i+1, j+1)].position);
        if ((normalizedNorm.length - 1).abs() > 0.0001) {
          print('ERROR: Length of normal does not equal 1.0');
        }
        perVertexNormals[getIndex(i+1, j)].add(normalizedNorm.clone());
        perVertexNormals[getIndex(i, j+1)].add(normalizedNorm.clone());
        perVertexNormals[getIndex(i+1, j+1)].add(normalizedNorm.clone());
        
      }
      
      // Average the calculated normals to get final normals. Store these
      // final numbers in the normal field of the corresponding vertex.
      for (int i = 0; i < perVertexNormals.length; i++) {
        Vector3 avgNorm = getAverageNorm(perVertexNormals[i]);
        vertices[i].normal = avgNorm;
      }
    }
  }
  
  Vector3 getAverageNorm(List<Vector3> norms) {
    Vector3 total = new Vector3.zero();
    for (var n in norms) {
      total += n;
    }
    return total.normalized();
  }
  
  /**
   * Calculate the normal direction, given 3 vertices making up a triangle
   */
  Vector3 getNormFromTriangle(Vector3 v1, Vector3 v2, Vector3 v3) {
    Vector3 v12 = v2 - v1;
    Vector3 v13 = v3 - v1;
    Vector3 norm = v12.cross(v13);
    return norm.normalized();
  }
  
  /**
   * Flatten the vertex array into a 1D array of Float32 objects. This makes
   * our meshes easier for the rendering system to handle.
   */
  void flattenVertices(List<Vertex> vertices) {
    vertexData = new Float32List(vertices.length * Vertex.size);
    
    for (int i = 0; i < vertices.length; i++) {   
      Float32List vxData = vertices[i].data;
      for (int j = 0; j < vxData.length; j++) {
        vertexData[i * Vertex.size + j] = vxData[j];
      }
    }
  }
  
  /**
   * Set up WebGL with a buffer for this mesh
   */
  void glSetup() {
    glVertexBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, vertexData, STATIC_DRAW);
    
    glIndexBuffer = gl.createBuffer();
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, new Int16List.fromList(indices), STATIC_DRAW);
  }
  
  int getIndex(r, c) {
    return r * cols + c;
  }
  
  void draw(ShaderProgram program) {
    mvPush();
    gl.useProgram(program.program);
    // Set up array buffer.
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.vertexAttribPointer(
        program.attributes['aPosition'], 3, FLOAT, 
        false, Vertex.size * FLOAT_SIZE, 0);
    gl.vertexAttribPointer(
        program.attributes['aNormal'], 3, FLOAT, 
        false, Vertex.size * FLOAT_SIZE, 3 * FLOAT_SIZE);
    
    // Set up index buffer.
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    
    // Set matrix uniforms
    mvp = proj * mv;
    gl.uniformMatrix4fv(program.uniforms['uMVP'], false, mvp.storage);
    
    // Draw lines for debugging purposes only
    //gl.drawElements(LINES, indices.length, UNSIGNED_SHORT, 0);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
    
    mvPop();
  }

}