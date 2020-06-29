/*
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The Original Code is Copyright (C) 2008 Blender Foundation.
 * All rights reserved.
 */

/** \file
 * \ingroup obj
 */

#ifndef __WAVEFRONT_OBJ_FILE_HANDLER_HH__
#define __WAVEFRONT_OBJ_FILE_HANDLER_HH__

#include <stdio.h>

#include "IO_wavefront_obj.h"

#include "wavefront_obj_exporter_mesh.hh"
#include "wavefront_obj_exporter_nurbs.hh"

namespace blender {
namespace io {
namespace obj {

/* Types of index offsets. */
enum index_offsets {
  VERTEX_OFF = 0,
  UV_VERTEX_OFF = 1,
  NORMAL_OFF = 2,
};

class OBJWriter {
 public:
  OBJWriter(const OBJExportParams *export_params) : _export_params(export_params)
  {
  }
  ~OBJWriter()
  {
    fclose(_outfile);
  }
  bool init_writer();
  /** When there are multiple objects in a frame, the indices of previous objects' coordinates or
   * normals add up. So one vertex or normal is referenced by only one object.
   */
  void update_index_offsets(OBJMesh &obj_mesh_data);

  /** Write object name as it appears in the outliner. */
  void write_object_name(OBJMesh &obj_mesh_data);
  /** Write file name of Material Library in OBJ file.
   * Also create an empty Material library file, or truncate the existing one.
   */
  void write_mtllib(const char *obj_filepath);
  /** Write vertex coordinates for all vertices as v x y z . */
  void write_vertex_coords(OBJMesh &obj_mesh_data);
  /** Write UV vertex coordinates for all vertices as vt u v
   * \note UV indices are stored here, but written later.
   */
  void write_uv_coords(OBJMesh &obj_mesh_data, Vector<Vector<uint>> &uv_indices);
  /** Write face normals for all polygons as vn x y z . */
  void write_poly_normals(OBJMesh &obj_mesh_data);
  /** Write material name and material group of a face in the OBJ file.
   * \note It doesn't write to the material library, MTL file.
   */
  void write_poly_material(short &last_face_mat_nr, OBJMesh &obj_mesh_data, short mat_nr);
  /** Define and write a face with at least vertex indices, and conditionally with UV vertex
   * indices and face normal indices. \note UV indices are stored while writing UV vertices.
   */
  void write_poly_indices(OBJMesh &obj_mesh_data, Span<Vector<uint>> uv_indices);

  /** Define and write an edge of a curve converted to mesh or a primitive circle as l v1 v2 . */
  void write_curve_edges(OBJMesh &obj_mesh_data);

  /** Write one nurbs of a curve. */
  void write_nurbs_curve(OBJNurbs &obj_nurbs_data);

 private:
  /** Destination OBJ file for one frame, and one writer instance. */
  FILE *_outfile;
  const OBJExportParams *_export_params;

  /** Vertex offset, UV vertex offset, face normal offset respetively. */
  uint _index_offset[3] = {0, 0, 0};

  /** Write one line of polygon indices as f v1 v2 .... */
  void write_vert_indices(Span<uint> vert_indices, const MPoly &poly_to_write);
  /** Write one line of polygon indices as f v1//vn1 v2//vn2 ... . */
  void write_vert_normal_indices(Span<uint> vert_indices,
                                 Span<uint> normal_indices,
                                 const MPoly &poly_to_write);
  /** Write one line of polygon indices as f v1/vt1 v2/vt2 ... . */
  void write_vert_uv_indices(Span<uint> vert_indices,
                             Span<uint> uv_indices,
                             const MPoly &poly_to_write);
  /** Write one line of polygon indices as f v1/vt1/vn1 v2/vt2/vn2 ... . */
  void write_vert_uv_normal_indices(Span<uint> vert_indices,
                                    Span<uint> uv_indices,
                                    Span<uint> normal_indices,
                                    const MPoly &poly_to_write);
};

}  // namespace obj
}  // namespace io
}  // namespace blender
#endif
