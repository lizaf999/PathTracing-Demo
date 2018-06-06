//
//  main.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation

let render = Render(width: 640, height: 480, samples: 256, superSample: 1)
let scene = SphereScene()
let radiance = RadianceSimple(scene: scene)
render.renderImage(radiance: radiance)
