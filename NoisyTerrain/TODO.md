Noisy Terrain TODO:

+ Move project to GitHub
- Test my terrain system
  - Should make sure the height maps are preserved when the terrain is created
    - Maybe just by saving the initial vertex array
    
    
Jan. 30
-------
Terrain vertex generation seems to be working fine.
 
- Make sure our objects render independently of world-space units
 
Next: Lighting system
- Calculate normals when mesh is generated
- Add diffuse, specular components to renderable objects
- Ambient component a part of the world?
  - Maybe implement lights with ambient built in (sounds cool)
- Write Phong shaders
- Test lighting system
 