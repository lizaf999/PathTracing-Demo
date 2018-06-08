//
//  Scene.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

let spheres:[Object] = [
//  Sphere(radius: 1e5, position: double3(1e5+1,40.8,81.6),//左
//         material: LambertianMaterial(Color(0.75,0.25,0.25))),
  Sphere(radius: 1e5, position: double3(-1e5+99,40.8,81.6),//右
         material: LambertianMaterial(Color(00,0x4e,0x92)/255)),
//  Sphere(radius: 1e5, position: double3(50,40.8,1e5),//奥
//         material: LambertianMaterial(Color(0.75))),
  Sphere(radius: 1e5, position: double3(50,40.8,-1e5+250),//背面
         material: LambertianMaterial(Color(0))),
  Sphere(radius: 1e5, position: double3(50,1e5,81.6),//床
         material: LambertianMaterial(Color(0.9))),
//  Sphere(radius: 1e5, position: double3(50,-1e5+81.6,81.6),//天井
//         material: LambertianMaterial(Color(0.75))),
  Sphere(radius: 20, position: double3(65,20,20),
         material: GlassMaterial(Color(0.25,0.75,0.25)/0.75)),
  Sphere(radius: 16.5, position: double3(27,16.5,47),
         material: SpecularMaterial(Color(0.99))),
  Sphere(radius: 16.5, position: double3(77,16.5,78),
         material: GlassMaterial(Color(0.9999), 1.5)),
//  Sphere(radius: 7, position: double3(50,73,81.6),
//         material: LightSource(Color(15))),
  Sphere(radius: 7, position: double3(90,72,160),
         material: LightSource(Color(10))),
  Sphere(radius: 7, position: double3(25,5,15),
         material: LightSource(Color(0xcc,0xfc,0xff)/255*30)),
  Sphere(radius: 15, position: double3(0,240,100),
         material: LightSource(Color(0xcc,0xfc,0xff)/255*80)),

]



class Scene {
  var objects:[Int:Object] = [:]
  var lightSource:[Int:Object] = [:]

  init() {}

  func intersect_scene(ray:Ray) -> (Bool,Intersection) {
    fatalError("method:\"intersect_scene is not implemented.\"")
  }
}

class SphereScene: Scene {

  override init() {
    super.init()
    for object in spheres {
      objects[object.objectID] = object
      if object.material is LightSource {
        lightSource[object.objectID] = object
      }
    }
  }

  override func intersect_scene(ray: Ray) -> (Bool,Intersection) {
    var intersection = Intersection(hitpoint: Hitpoint(), object_id: -1)

    intersection.hitpoint.distance = kINF
    for object in objects.values {
      let (isIntersect,hitpoint) = object.intersect(ray: ray)
      if isIntersect {
        if hitpoint.distance < intersection.hitpoint.distance {
          intersection.hitpoint = hitpoint
          //FIXME: object_id vs objectID
          intersection.object_id = object.objectID
        }
      }
    }

    return (intersection.object_id != -1, intersection)
  }
}














