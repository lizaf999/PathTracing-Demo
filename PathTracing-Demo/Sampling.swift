//
//  Sampling.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/6/18.
//

import Foundation
import simd

class Sampling {
  static func cosineWeightedHemisphereSurface(normal:double3, tangent:double3, binormal:double3) -> double3 {
    let phi:double_t = rand(from: 0, to: 2*double_t.pi)
    let r2:double_t = rand01()
    let r2s = sqrt(r2)
    let tx = r2s * cos(phi)
    let ty = r2s * sin(phi)
    let tz = sqrt( 1-r2 )
    return (tz*normal) + (tx*tangent) + (ty*binormal)

  }
}
