//
//  Ray.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

struct Ray {
  var org:double3
  var dir:double3

  init(_ origin:double3,_ dir:double3) {
    self.org = origin
    self.dir = dir
  }

}
