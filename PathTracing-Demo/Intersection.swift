//
//  Intersection.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

struct Hitpoint {
  var distance:double_t = 1001001001
  var normal = double3(0)
  var position = double3(0)
}

struct Intersection {
  var hitpoint = Hitpoint()
  var object_id:Int = -1
}
