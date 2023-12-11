//
//  Uniforms.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import simd

// Transformation matrices specific to the object.
struct ObjectConstants {
	var mvp = matrix_identity_float4x4
	var invmv = matrix_identity_float4x4
	var mv = matrix_identity_float4x4
	var mvpLight = matrix_identity_float4x4
}


// Material parameters.
struct MaterialConstants {
	var shininess : Int = 0
}


// Scene parameters.
struct GlobalConstants {
	var lightDir = float4(0.0)
}
