//
//  Material.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

typealias Color = double3

enum ReflectionType {
  case DIFFUSE
  case SPECULAR
  case REFRACTION
}

let kIor:double_t = 1.5//屈折率

class Material {
  var emission:Color = Color(0)
  var color:Color = Color(0)
  var reflectionType:ReflectionType = ReflectionType.DIFFUSE

  init() {}

  init(emission:Color, color: Color, reflectionType:ReflectionType) {
    self.emission = emission
    self.color = color
    self.reflectionType = reflectionType
  }
}

protocol LightSource {
  var area:double_t {get}
  func getPoint() -> double3
}
