part of noisyterrain;

class Material {
  Vector3 ambient;
  Vector3 diffuse;
  Vector3 specular;
  double shine;
  
  Material(ambient, diffuse, specular, [shine=0.0]) {
    this.ambient = ambient;
    this.diffuse = diffuse;
    this.specular = specular;
    this.shine = shine;
  }
}