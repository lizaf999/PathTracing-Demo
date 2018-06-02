//
//  Ray.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

class Ray {
  var org = double3(0)
  var dir = double3(0)

  init() {}

  func initialize(origin:double3, dir:double3) -> Ray {
    self.org = origin
    self.dir = dir
    var ray = Ray()
    ray.org = origin
    ray.dir = dir
    return ray
  }

}
