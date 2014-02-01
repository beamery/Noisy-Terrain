part of noisyterrain;

class Terrain {
  var mesh;
  var sizeX;
  var sizeZ;
  
  Terrain(rows, cols, [heightMap=null]) {
    List<Vertex> vertices = new List<Vertex>(rows * cols);
    
    // Initialize the mesh array based on the height map
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        vertices[i*cols + j] = new Vertex.zero();
        
        // If a height map is supplied, use it. Otherwise, set heights to 0.
        if (heightMap == null) {
          vertices[i*cols + j].position = 
              new Vector3(i.toDouble(), 0.0, j.toDouble());
        }
        else {
          vertices[i*cols + j].position = 
              new Vector3(i.toDouble(), heightMap[i*cols + j], j.toDouble());
        }
      }
    }
    mesh = new Mesh(vertices, rows, cols);
    
    // (rows, cols) vertices => grid of size (rows-1, cols-1)
    sizeX = cols - 1;
    sizeZ = rows - 1;
  }
  
  void draw(ShaderProgram program) {
    mesh.draw(program);
  }
}