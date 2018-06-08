//
//  Sphere.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

class Object {
  static private var currentObjectID:Int = 0

  var material:Material
  private var _objectID:Int = -1
  var objectID:Int {
    get {
      if(_objectID == -1){
        Object.currentObjectID += 1//1始まり
        _objectID = Object.currentObjectID
      }
      return _objectID
    }
  }

  //for Next Event Estimation
  var area:double_t = 0
  func getRandomPoint() -> (double3,double3) {
    return (double3(0),double3(0))
  }


  init(material:Material) {
    self.material = material
  }

  func intersect(ray:Ray) -> (Bool,Hitpoint) {
    fatalError("method:\"intesect\" is not implemented.")
  }
}

class Sphere: Object{
  let radius:double_t
  var position:double3

  init(radius:double_t, position:double3, material:Material) {
    self.radius = radius
    self.position = position
    super.init(material: material)

    area = 4*double_t.pi*radius*radius
  }

  override func getRandomPoint() -> (double3,double3) {
    let x:double_t = rand01()
    let y:double_t = rand01()
    let z:double_t = rand01()
    let n = normalize(double3(x,y,z))
    return (position + radius*n, n)
  }

  override func intersect(ray: Ray) -> (Bool, Hitpoint) {
    var hitpoint = Hitpoint()

    let p_o:double3 = position-ray.org
    let b:double_t = dot(p_o, ray.dir)
    let D4:double_t = b*b - dot(p_o, p_o) + radius*radius

    if D4<0 {
      return (false,hitpoint)
    }

    let sqrt_D4:double_t = sqrt(D4)
    let t1:double_t = b - sqrt_D4
    let t2:double_t = b + sqrt_D4

    if t1<kEPS && t2 < kEPS {
      return (false,hitpoint)
    }
    if t1>kEPS {
      hitpoint.distance = t1
    }else{
      hitpoint.distance = t2
    }

    hitpoint.position = ray.org + hitpoint.distance*ray.dir
    hitpoint.normal = normalize(hitpoint.position - position)

    return (true,hitpoint)
  }
}









