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

class RadianceSimple: Radiance {
  let backgroundColor = Color(0)
  let maxDepth:Int = 32
  let minDepth:Int = 10

  override func calcRadiance(ray: Ray, depth: Int) -> Color {

    let isIntersect = scene.intersect_scene(ray: ray)
    if !isIntersect.0 {
      return backgroundColor
    }

    let intersection = isIntersect.1
    guard let nowObj = scene.objects[intersection.object_id]
      else {
        fatalError("unexpected error: target object is null")
    }
    let hitpoint = intersection.hitpoint
    let material = nowObj.material
    let emission = material.emission
    if emission.x > 0 || emission.y > 0 || emission.z > 0 {
      return emission
    }
    let orientingNormal:double3 = dot(hitpoint.normal, ray.dir) < 0 ? hitpoint.normal : -hitpoint.normal
    var russianRouletteProbability = max(material.reflectance.x,material.reflectance.y,material.reflectance.z)

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


    var pdf:double_t = -1
    var brdfValue = Color(-1)
    let dirOut:double3 = material.sample(in: ray.dir, normal: orientingNormal, pdf: &pdf, brdfValue: &brdfValue)

    let cost:double_t = dot(orientingNormal, dirOut)

    let L:Color = brdfValue*calcRadiance(ray: Ray(hitpoint.position,dirOut), depth: depth+1) * cost/pdf
    return L
  }
}

class RadianceNEE: Radiance {
  let backgroundColor = Color(0)
  let maxDepth:Int = 64
  let minDepth:Int = 10

  override func calcRadiance(ray: Ray, depth: Int) -> Color {
    let isIntersect = scene.intersect_scene(ray: ray)
    if !isIntersect.0 {
      return backgroundColor
    }

    let intersection = isIntersect.1
    guard let nowObj = scene.objects[intersection.object_id]
      else {
        fatalError("unexpected error: target object is null")
    }
    let hitpoint = intersection.hitpoint
    let material = nowObj.material
    let emission = material.emission
    if emission.x > 0 || emission.y > 0 || emission.z > 0 {
      if depth==0 || ray.fromSpecular {
        return emission
      }else{
        return Color(0)
      }
    }

    let orientingNormal:double3 = dot(hitpoint.normal, ray.dir) < 0 ? hitpoint.normal : -hitpoint.normal

    //Next Event Estimation
    var Ls:Color = Color(0)
    if material is LambertianMaterial {
      for obj in scene.lightSource.values {
        let (lsPos,lsNormal):(double3,double3) = obj.getRandomPoint()
        let shadowRay = Ray(hitpoint.position,normalize(lsPos-hitpoint.position))

        let obstacle = scene.intersect_scene(ray: shadowRay)
        //遮蔽の有無
        if obstacle.0 && obstacle.1.object_id != obj.objectID {
          continue
        }

        //FIXME: area!=0は不適切
        if obj.area != 0 {
          let le:Color = calcRadiance(ray: shadowRay, depth: 0)
          let brdf = material.eval(in: ray.dir, normal: orientingNormal, out: shadowRay.dir)
          let cost:double_t = dot(orientingNormal, shadowRay.dir)
          let fs:Color = brdf*cost
          let g1:double_t =
            abs(dot(shadowRay.dir, orientingNormal)) * abs(dot(shadowRay.dir, lsNormal))
          let g2:double_t = pow(length(lsPos-hitpoint.position), 2)
          let G:double_t = g1/g2
          Ls += le*fs*G*obj.area
        }
      }
    }



    var russianRouletteProbability = max(material.reflectance.x,material.reflectance.y,material.reflectance.z)

    if depth>maxDepth {
      russianRouletteProbability *= pow(0.5, double_t(depth-maxDepth))
    }
    if depth>minDepth {
      if rand01() >= russianRouletteProbability {
        if ray.fromSpecular {
          return Ls//NEE
        }else{
          return Color(0)
        }

      }
    }else{
      russianRouletteProbability = 1
    }

    var pdf:double_t = -1
    var brdfValue = Color(-1)
    let dirOut:double3 = material.sample(in: ray.dir, normal: hitpoint.normal, pdf: &pdf, brdfValue: &brdfValue)

    let cost:double_t = abs(dot(orientingNormal, dirOut))

    var nextRay = Ray(hitpoint.position,dirOut)
    if !(material is LambertianMaterial) {
      nextRay.fromSpecular = true
    }

    let L:Color = brdfValue*calcRadiance(ray: nextRay, depth: depth+1) * cost/pdf
    return L+Ls
  }
}















