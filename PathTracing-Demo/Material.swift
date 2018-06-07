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

//class Material {
//  var emission:Color = Color(0)
//  var color:Color = Color(0)
//  var reflectionType:ReflectionType = ReflectionType.DIFFUSE
//
//  init() {}
//
//  init(emission:Color, color: Color, reflectionType:ReflectionType) {
//    self.emission = emission
//    self.color = color
//    self.reflectionType = reflectionType
//  }
//}
//
//protocol LightSource {
//  var area:double_t {get}
//  func getPoint() -> double3
//}

protocol Material {
  var emission:Color {get}
  var reflectance:Color {get}

  func eval(in vecIn:double3, normal:double3, out:double3)->Color
  func sample(in vecIn:double3, normal:double3, pdf:inout double_t, brdfValue:inout Color) -> double3
}

class LambertianMaterial: Material {
  var emission: Color
  var reflectance: Color

  init(_ reflectance:Color) {
    self.emission = Color(0)
    self.reflectance = reflectance
  }

  func eval(in vecIn: double3, normal: double3, out vecOut: double3) -> Color {
    return reflectance / double_t.pi
  }

  func sample(in vecIn: double3, normal: double3, pdf: inout double_t, brdfValue: inout Color) -> double3 {
    let (tangent,binormal):(double3,double3) = createOrthoNormalBasis(normal: normal)
    let dir:double3 = Sampling.cosineWeightedHemisphereSurface(normal: normal, tangent: tangent, binormal: binormal)

    // MARK: サンプルと違う
    if pdf != 0 {
      pdf = dot(normal, dir) / double_t.pi
    }
    if brdfValue.x != 0 || brdfValue.y != 0 || brdfValue.z != 0 {
      brdfValue = eval(in: vecIn, normal: normal, out: dir)
    }
    return dir
    
  }
}

class GlassMaterial: Material {
  var emission: Color
  var reflectance: Color
  let DELTA:double_t = 1

  let ior:double_t
  init(_ reflectance:Color, _ ior:double_t = 1.5) {
    self.emission = Color(0)
    self.reflectance = reflectance
    self.ior = ior
  }

  func eval(in vecIn: double3, normal: double3, out vecOut: double3) -> Color {
    return reflectance * DELTA / abs(dot(normal, vecOut))
  }

  func sample(in vecIn: double3, normal: double3, pdf: inout double_t, brdfValue: inout Color) -> double3 {
    let now_normal:double3 = dot(normal, vecIn) < 0 ? normal : -normal
    let into:Bool = dot(normal, now_normal) > 0
    let n1:double_t = 1//真空の屈折率
    let n2:double_t = ior
    let n:double_t = into ? n1/n2 : n2/n1

    let ddn:double_t = dot(vecIn,now_normal)
    let cos2t_2:double_t = 1-n*n*(1-ddn*ddn)

    //全反射
    let reflectioDir:double3 = normalize(vecIn - normal*2*dot(normal, vecIn))
    if cos2t_2<0 {
      // MARK: サンプルと違う
      if pdf != 0 {
        pdf = DELTA
      }
      if brdfValue.x != 0 || brdfValue.y != 0 || brdfValue.z != 0 {
        brdfValue  = eval(in: vecIn, normal: normal, out: reflectioDir)
      }
      return reflectioDir
    }

    //屈折方向
    let refractionDir:double3 = vecIn*n - now_normal*(ddn*n + sqrt(cos2t_2))

    //Fresnel
    let cost_1:double_t = dot(-vecIn, now_normal)
    let cost_2:double_t = sqrt(cos2t_2)
    let r_parallel:double_t = (n*cost_1 - cost_2) / (n*cost_1 + cost_2)
    let r_perpendicular:double_t = (cost_1 - n*cost_2) / (cost_1 + n*cost_2)
    let Fr:double_t = 0.5*(r_parallel*r_parallel + r_perpendicular*r_perpendicular)

    let factor:double_t = pow(n, 2)
    let Ft:double_t = (1-Fr)*factor

    //ロシアンルーレットで屈折か反射かを決定(再帰はしない)
    // FIXME: schlickは使わない？
    let probability:double_t = Fr
    if rand01()<probability{//反射
      // MARK: サンプルと違う
      if pdf != 0 {
        pdf = DELTA*probability
      }
      if brdfValue.x != 0 || brdfValue.y != 0 || brdfValue.z != 0 {
        brdfValue  = Fr*eval(in: vecIn, normal: normal, out: reflectioDir)
      }
      return reflectioDir
    }else{//屈折
      // MARK: サンプルと違う
      if pdf != 0 {
        pdf = DELTA*(1-probability)
      }
      if brdfValue.x != 0 || brdfValue.y != 0 || brdfValue.z != 0 {
        brdfValue  = Ft*eval(in: vecIn, normal: normal, out: reflectioDir)
      }
      return refractionDir
    }


  }
}

class SpecularMaterial: Material {
  var emission: Color
  var reflectance: Color

  init(_ reflectance:Color) {
    self.reflectance = reflectance
    self.emission = Color(0)
  }

  func eval(in vecIn: double3, normal: double3, out: double3) -> Color {
    return reflectance / double_t.pi
  }

  func sample(in vecIn: double3, normal: double3, pdf: inout double_t, brdfValue: inout Color) -> double3 {
    let dirOut:double3 = vecIn-normal*2*dot(normal, vecIn)
    if pdf != 0 {
      pdf = dot(normal, dirOut) / double_t.pi
    }
    if brdfValue.x != 0 || brdfValue.y != 0 || brdfValue.z != 0 {
      brdfValue = eval(in: vecIn, normal: normal, out: dirOut)
    }
    return dirOut
  }
}

/**
 反射しない
 */
class LightSource: Material {
  var emission: Color
  var reflectance: Color

  init(_ emission:Color) {
    self.emission = emission
    reflectance = Color(0)
  }

  func eval(in vecIn: double3, normal: double3, out: double3) -> Color {
    assert(false)
    return Color(0)
  }

  func sample(in vecIn: double3, normal: double3, pdf: inout double_t, brdfValue: inout Color) -> double3 {
    assert(false)
    return Color(0)
  }


}










