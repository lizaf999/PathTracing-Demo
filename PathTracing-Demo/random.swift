//
//  random.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation

func rand01() -> Double {
  return Double(arc4random_uniform(UINT32_MAX))/Double(UINT32_MAX)
}

func rand(from:Double, to:Double) -> Double {
  return rand01()*(to-from)
}
