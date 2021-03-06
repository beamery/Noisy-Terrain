/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

part of vector_math_geometry;

class InvertFilter extends InplaceGeometryFilter {
  void filterInplace(MeshGeometry mesh) {
    // TODO: Do the tangents need to be inverted? Maybe just the W component?
    // TODO: Should modify in-place be allowed, or should it be required
    // to return a new geometry?

    // Swap all the triangle indices
    for (int i = 0; i < mesh.indices.length; i += 3) {
      int tmp = mesh.indices[i];
      mesh.indices[i] = mesh.indices[i + 2];
      mesh.indices[i + 2] = tmp;
    }

    Vector3List normals = mesh.getViewForAttrib('NORMAL');
    if (normals != null) {
      for (int i = 0; i < normals.length; ++i) {
        normals[i] = -normals[i];
      }
    }
  }
}
