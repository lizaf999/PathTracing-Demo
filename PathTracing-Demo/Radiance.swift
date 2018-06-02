//
//  Radiance.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

class Radiance {
  //virtual class
  let scene:Scene
  init(scene:Scene) {
    self.scene = scene
  }

  func calcRadiance(ray:Ray, depth:Int) -> Color {
    return Color(0)
  }
}


class RadianceBSDF: Radiance {
  let minDepth:Int = 5
  let maxDepth:Int = 64

  let backgroundColor = Color(0,0,0)

  override func calcRadiance(ray: Ray, depth: Int) -> Color {
    let isIntersect = scene.intersect_scene(ray: ray)
    if !isIntersect.0 {
      return backgroundColor
    }
    let intersection = isIntersect.1

    guard let nowObj = scene.objects[intersection.object_id]
    else {
      print("unexpected error: target object is null")
      return Color(0)
    }
    let hitpoint = intersection.hitpoint
    let orientingNormal:double3 = dot(hitpoint.normal, ray.dir) < 0 ? hitpoint.position : -hitpoint.normal
    let objMat:Material = nowObj.material
    var russianRouletteProbability = max(objMat.color.x,objMat.color.y,objMat.color.z)

    if depth>maxDepth {
      russianRouletteProbability += pow(0.5, double_t(depth-maxDepth))
    }
    if depth>minDepth {
      if rand01() >= russianRouletteProbability {
        return nowObj.material.emission
      }
    }else{
      russianRouletteProbability = 1
    }

    var incomingRadiance = Color(0)
    var weight = Color(1)

    switch nowObj.material.reflectionType {
    case .DIFFUSE:
      var w,u,v:double3
      w = orientingNormal
      if abs(w.x)>kEPS {
        u = normalize(cross(double3(0,1,0), w))
      }else{
        u = normalize(cross(double3(1,0,0), w))
      }
      v = cross(w, u)

      let r1:double_t = 2*double_t.pi*rand01()
      let r2:double_t = rand01()
      let r2s:double_t = sqrt(r2)
      let dir:double3 = normalize(u*cos(r1)*r2s + v*sin(r1)*r2s + w*sqrt(1-r2))

      let nextRay = ray.initialize(origin: hitpoint.position, dir: dir)
      incomingRadiance = calcRadiance(ray: nextRay, depth: depth+1)

      weight = nowObj.material.color / russianRouletteProbability

    case .SPECULAR:
      let nextRay = ray.initialize(origin: hitpoint.position, dir: ray.dir-hitpoint.normal*2*dot(hitpoint.normal, ray.dir))
      incomingRadiance = calcRadiance(ray: nextRay, depth: depth+1)
      weight = nowObj.material.color / russianRouletteProbability

    case .REFRACTION:
      let reflectionRay = ray.initialize(origin: hitpoint.position, dir: ray.dir-hitpoint.normal*2*dot(hitpoint.normal, ray.dir))
      let into:Bool = dot(hitpoint.normal, orientingNormal) > 0

      let nc:double_t = 1//真空の屈折率
      let nt:double_t = kIor
      let nnt:double_t = into ? nc/nt : nt/nc
      let ddn:double_t = dot(ray.dir, orientingNormal)
      let cos2t:double_t = 1 - nnt*nnt*(1-ddn*ddn)

      if cos2t < 0 {//全反射
        incomingRadiance = calcRadiance(ray: reflectionRay, depth: depth+1)
        weight = nowObj.material.color / russianRouletteProbability
        break
      }

      let fac:double_t = (into ? 1:-1)*(ddn*nnt+sqrt(cos2t))
      let refractionRay = ray.initialize(origin: hitpoint.position, dir: normalize(ray.dir*nnt - hitpoint.normal*fac))
      //schlick
      let a:double_t = nt-nc, b:double_t = nt+nc
      let R0:double_t = (a*a)/(b*b)

      let c:double_t = 1 - (into ? -ddn : dot(refractionRay.dir, -1*orientingNormal))
      let Re:double_t = R0 + (1-R0)*pow(c, 5)
      let nnt2:double_t = pow(into ? nc/nt : nt/nc, 2)//nntでは
      let Tr:double_t = (1-Re)*nnt2

      let probability:double_t = 0.25+0.5*Re
      if depth > 2 {
        if rand01()<probability {
          incomingRadiance = calcRadiance(ray: reflectionRay, depth: depth+1) * Re
          weight = nowObj.material.color / (probability*russianRouletteProbability)
        }else{
          incomingRadiance = calcRadiance(ray: refractionRay, depth: depth+1) * Tr
          weight = nowObj.material.color / ((1-probability)*russianRouletteProbability)
        }
      }else{
        incomingRadiance = calcRadiance(ray: reflectionRay, depth: depth+1)*Re + calcRadiance(ray: refractionRay, depth: depth+1)*Tr
        weight = nowObj.material.color / russianRouletteProbability
      }


    }

    return nowObj.material.emission + weight*incomingRadiance
  }


}
