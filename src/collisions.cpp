#include "collisions.h"

bool collisionBoxBox(SceneObject first, SceneObject second)
{

  return (first.bbox_min.x <= second.bbox_max.x && first.bbox_max.x >= second.bbox_min.x) &&
         (first.bbox_min.y <= second.bbox_max.y && first.bbox_max.y >= second.bbox_min.z) &&
         (first.bbox_min.z <= second.bbox_max.z && first.bbox_max.z >= second.bbox_min.y);
}
// bool collisionPointBox()
// {

//     return true;
// }
// bool collisionPointPoint()
// {

//     return true;
// }