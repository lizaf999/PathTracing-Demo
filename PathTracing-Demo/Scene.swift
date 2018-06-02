//
//  Scene.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

let spheres:[Object] = [
  Sphere(radius: 1e5, position: double3(1e5+1,40.8,81.6), material: Material(emission: Color(0), color: Color(0.75,0.25,0.25), reflectionType: .DIFFUSE)),
  Sphere(radius: 1e5, position: double3(-1e5+99,40.8,81.6), material: Material(emission: Color(0), color: Color(0.25,0.25,0.75), reflectionType: .DIFFUSE)),
  Sphere(radius: 1e5, position: double3(50,40.8,1e5), material: Material(emission: Color(0), color: Color(0.75,0.75,0.75), reflectionType: .DIFFUSE)),
  Sphere(radius: 1e5, position: double3(50,40.8,-1e5+250), material: Material(emission: Color(0), color: Color(0), reflectionType: .DIFFUSE)),
  Sphere(radius: 1e5, position: double3(50,1e5,81.6), material: Material(emission: Color(0), color: Color(0.75,0.75,0.75), reflectionType: .DIFFUSE)),
  Sphere(radius: 1e5, position: double3(50,-1e5+81.6,81.6), material: Material(emission: Color(0), color: Color(0.75,0.75,0.75), reflectionType: .DIFFUSE)),
  Sphere(radius: 20, position: double3(65,20,20), material: Material(emission: Color(0), color: Color(0.25,0.75,0.25), reflectionType: .DIFFUSE)),
  Sphere(radius: 16.5, position: double3(27,16.5,47), material: Material(emission: Color(0), color: Color(0.99), reflectionType: .SPECULAR)),
  Sphere(radius: 16.5, position: double3(77,16.5,78), material: Material(emission: Color(0), color: Color(0.99), reflectionType: .REFRACTION)),
  Sphere(radius: 15, position: double3(50,90,81.6), material: Material(emission: Color(36), color: Color(0), reflectionType: .DIFFUSE))
]

class Scene {
  var objects:[Int:Object] = [:]

  init() {}

  func intersect_scene(ray:Ray) -> (Bool,Intersection) {
    fatalError("method:\"intersect_scene is not implemented.\"")
    return (false,Intersection(hitpoint: Hitpoint(), object_id: -1))
  }
}

class SphereScene: Scene {

  override init() {
    super.init()
    for object in spheres {
      objects[object.objectID] = object
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


