part of noisyterrain;

class TerrainFragment {
  Mesh mesh;
  Grid2D<double> heightMap;
  num sizeX;
  num sizeZ;
  
  /**
   * Create terrain of dimensions rows x cols, with optional heightmap.
   */
  TerrainFragment(rows, cols, [Grid2D<double> heightMap=null]) {
    // Keep a copy of the height map attached to this terrain segment.
    if (heightMap == null) {
      this.heightMap = new Grid2D<double>(rows, cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          heightMap[i][j] = 0.0;
        }
      }
    }
    else {
      this.heightMap = heightMap;
    }
    
    Grid2D<Vertex> vertices = new Grid2D<Vertex>(rows, cols);
    //List<Vertex> vertices = new List<Vertex>(rows * cols);
    
    // Initialize the mesh array based on the height map
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        vertices[i][j] = new Vertex.zero();
        
        // If a height map is supplied, use it. Otherwise, set heights to 0.
        if (heightMap == null) {
          vertices[i][j].position = 
              new Vector3(i.toDouble(), 0.0, j.toDouble());
        }
        else {
          vertices[i][j].position = 
              new Vector3(i.toDouble(), heightMap[i][j], j.toDouble());
        }
      }
    }
    
    Material mat = new Material(
        new Vector3(0.1, 0.3, 0.1), 
        new Vector3(0.4, 0.7, 0.4), 
        new Vector3(0.1, 0.2, 0.1), 10.0);
    
    mesh = new Mesh(vertices, mat);
    
    // (rows, cols) vertices => grid of size (rows-1, cols-1)
    sizeX = cols - 1;
    sizeZ = rows - 1;
  }
  
  void draw(ShaderProgram program) {
    mesh.draw(program);
  }
}