//
//  random.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation

func rand(from:Double,to:Double) -> Double {
  return Double(arc4random_uniform(UINT32_MAX))/Double(UINT32_MAX)*(to-from)
}

func rand01() -> Double {
  return rand(from: 0, to: 1)
}
