//
//  main.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation

let render = Render(width: 640, height: 480, samples: 256, superSample: 2)
let scene = SphereScene()
let radiance = RadianceBSDF(scene: scene)
render.renderImage(radiance: radiance)
