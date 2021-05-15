
#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>
#include <glm/gtc/type_ptr.hpp>

struct SceneObject
{
  std::string name;              // Nome do objeto
  size_t first_index;            // Índice do primeiro vértice dentro do vetor indices[] definido em BuildTrianglesAndAddToVirtualScene()
  size_t num_indices;            // Número de índices do objeto dentro do vetor indices[] definido em BuildTrianglesAndAddToVirtualScene()
  GLenum rendering_mode;         // Modo de rasterização (GL_TRIANGLES, GL_TRIANGLE_STRIP, etc.)
  GLuint vertex_array_object_id; // ID do VAO onde estão armazenados os atributos do modelo
  glm::vec3 bbox_min;            // Axis-Aligned Bounding Box do objeto
  glm::vec3 bbox_max;
};

bool collisionBoxBox(SceneObject first, SceneObject second);

bool collisionBoxBox(SceneObject first, SceneObject second)
{
  return (first.bbox_min.x <= second.bbox_max.x && first.bbox_max.x >= second.bbox_min.x) &&
         (first.bbox_min.y <= second.bbox_max.y && first.bbox_max.y >= second.bbox_min.z) &&
         (first.bbox_min.z <= second.bbox_max.z && first.bbox_max.z >= second.bbox_min.y);
}