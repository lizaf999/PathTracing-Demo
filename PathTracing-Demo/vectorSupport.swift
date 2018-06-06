//
//  vectorSupport.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/6/18.
//

import Foundation
import simd

/**
 正規直交基底を生成する
 - returns: (tangent,binormal)
*/
func createOrthoNormalBasis(normal:double3) -> (double3,double3) {
  var tangent = double3(0), binormal = double3(0)
  if abs(normal.x) > abs(normal.y) {
    tangent = normalize(cross(double3(0,1,0), normal))
  }else{
    tangent = normalize(cross(double3(1,0,0), normal))
  }
  binormal = normalize(cross(normal, tangent))

  return (tangent,binormal)
}

