//
//  main.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation

let render = Render(width: 160, height: 120, samples: 4, superSample: 1)
let scene = SphereScene()
let radiance = RadianceBSDF(scene: scene)
render.renderImage(radiance: radiance)
