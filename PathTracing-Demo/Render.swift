//
//  Render.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

class Render {
  let width:Int
  let height:Int
  let samples:Int
  let superSapmles:Int

  private(set) var camera_pos = double3(50,52,220)
  private(set) var camera_dir = normalize(double3(0,-0.04,-1))
  private(set) var camera_up  = double3(0,1,0)

  private(set) var screen_width:double_t = 0
  private(set) var screen_height:double_t = 0
  private(set) var screen_dist:double_t = 40

  private(set) var screen_x = double3(0)
  private(set) var screen_y = double3(0)
  private(set) var screen_center = double3(0)


  init(width:Int,height:Int,samples:Int,superSample:Int) {
    self.width = width
    self.height = height
    self.samples = samples
    self.superSapmles = samples
  }

  func setCameraProp(pos:double3,dir:double3,up:double3) {
    camera_pos = pos
    camera_dir = dir
    camera_up  = up
  }

  private func setScreen() {
    screen_width = 30*double_t(width)/double_t(height)
    screen_height = 30
    screen_x = normalize(cross(camera_dir, camera_up))*screen_width
    screen_y = normalize(cross(screen_x, camera_dir))*screen_height
    screen_center = camera_pos+camera_dir*screen_dist
  }

  func renderImage(radiance:Radiance) {
    setScreen()

    var pixels:[[Color]] = Array(repeating: Array(repeating: Color(0), count: width), count: height)
    for y in 0..<height {
      let rate = String(format: "%.2f", arguments: [double_t(y)/double_t(height)*100])
      print("Rendering y=\(y)/\(height-1) " + rate + "%")
      for x in 0..<width {
        for sy in 0..<superSapmles {
          for sx in  0..<superSapmles {
            var accumulated_radiance = Color(0)
            for _ in 0..<samples {
              let rate:double_t = 1/double_t(superSapmles)
              let r1:double_t = double_t(sx)*rate / rate*2
              let r2:double_t = double_t(sy)*rate / rate*2

              let xOffset:double3 = screen_x*((r1+double_t(x))/double_t(width)-0.5)
              let yOffset:double3 = screen_y*((r2+double_t(y))/double_t(height)-0.5)
              let posOnScreen:double3 = screen_center + xOffset + yOffset

              let rayDir:double3 = normalize(posOnScreen - camera_pos)

              let nextRay = Ray(origin: camera_pos, dir: rayDir)
              accumulated_radiance += radiance.calcRadiance(ray: nextRay, depth: 0) / double_t(samples) / double_t(superSapmles*superSapmles)
            }
            pixels[y][x] += accumulated_radiance
          }
        }
      }
    }

    let writer = ImageWriter(width: width, height: height)
    for y in 0..<height {
      for x in 0..<width {
        //FIXME: 整理されていない
        var col:Color = pixels[y][x]
        col = Color(pow(col.x, 1/2.2),pow(col.y, 1/2.2),pow(col.z, 1/2.2))
        //上下逆
        writer.data[x][height-y-1] = ImageWriter.Color(Red: col.x, Green: col.y, Blue: col.z)
      }
    }
    writer.makeImage()

  }
}










