//
//  MatrixUtilities.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import simd

// Create a look-at matrix
func lookAtMatrix(eye : SIMD3<Float>, target : SIMD3<Float>, up : SIMD3<Float>) -> matrix_float4x4 {
	let zaxis = normalize(eye - target)
	var yaxis = normalize(up)
	let xaxis = normalize(cross(yaxis, zaxis))
	yaxis = normalize(cross(zaxis, xaxis))
	
	let col0 = SIMD4<Float>(xaxis.x, yaxis.x, zaxis.x, 0.0)
	let col1 = SIMD4<Float>(xaxis.y, yaxis.y, zaxis.y, 0.0)
	let col2 = SIMD4<Float>(xaxis.z, yaxis.z, zaxis.z, 0.0)
	let col3 = SIMD4<Float>(-dot(xaxis,eye), -dot(yaxis,eye), -dot(zaxis,eye), 1.0)
	
	return matrix_float4x4(columns: (col0,col1,col2,col3))
}

// Create a perspective projection matrix
func perspectiveMatrix(fov: Float, aspect: Float, near: Float, far: Float) -> matrix_float4x4 {
	var matrix = matrix_float4x4()
	let f = 1.0 / tanf(fov / 2.0)
	
	(matrix.columns.0)[0] = f / aspect
	(matrix.columns.1)[1] = f
	(matrix.columns.2)[2] = (far + near) / (near - far)
	(matrix.columns.2)[3] = -1.0
	(matrix.columns.3)[2] = (2.0 * far * near) / (near - far)
	
	return matrix
}

// Create an orthographic projection matrix
func orthographyMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> matrix_float4x4 {
	return matrix_make4x4(2.0/(right - left), 0, 0, 0,
	                      0, 2.0/(top - bottom), 0, 0,
	                      0, 0, 2.0/(near - far), 0,
	                      (right+left)/(left-right), (top + bottom)/(bottom - top), (far + near)/(near - far), 1.0)
}

// Extract a 3x3 matrix from a 4x4 matrix
func matrix_block3x3(m : matrix_float4x4) -> matrix_float3x3 {
	let col0 = SIMD3<Float>(m.columns.0.x, m.columns.0.y, m.columns.0.z)
	let col1 = SIMD3<Float>(m.columns.1.x, m.columns.1.y, m.columns.1.z)
	let col2 = SIMD3<Float>(m.columns.2.x, m.columns.2.y, m.columns.3.z)
	return matrix_float3x3(columns: (col0,col1,col2))
}

// Compute the transpose inverse of a 3x3 matrix
func matrix_transpose_inverse(m : matrix_float3x3) -> matrix_float3x3 {
	return m.inverse.transpose
}

// Compute the inverse transpose of a 4x4 matrix
func matrix_inverse_transpose(m : matrix_float4x4) -> matrix_float4x4 {
	return m.transpose.inverse
}

// Create a 4x4 matrix with specified elements
func matrix_make4x4(_ m00 : Float, _ m01: Float, _ m02: Float, _ m03: Float,
                    _ m10: Float, _ m11: Float, _ m12: Float, _ m13: Float,
                    _ m20: Float, _ m21: Float, _ m22: Float, _ m23: Float,
                    _ m30: Float, _ m31: Float, _ m32: Float, _ m33: Float) -> matrix_float4x4 {
	return matrix_float4x4(columns: (
        SIMD4<Float>(m00, m10, m20, m30),
        SIMD4<Float>(m01, m11, m21, m31),
        SIMD4<Float>(m02, m12, m22, m32),
        SIMD4<Float>(m03, m13, m23, m33) ))
}

// Create a rotation matrix around an axis
func matrix_rotation(angle: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
	let c = cosf(angle)
	let ci = 1.0 - c
	let s = sinf(angle)
	
	let xy = axis.x * axis.y * ci
	let xz = axis.x * axis.z * ci
	let yz = axis.y * axis.z * ci
	let xs = axis.x * s
	let ys = axis.y * s
	let zs = axis.z * s
	
	return matrix_make4x4(axis.x * axis.x * ci + c, xy - xz, xz + ys, 0.0,
	                      xy + zs, axis.y * axis.y * ci + c, yz - xs, 0.0,
	                      xz - ys, yz + xs, axis.z * axis.z * ci + c, 0.0,
	                      0.0, 0.0, 0.0, 1.0)
}

// Ccreate a scaling matrix
func matrix_scaling(scale: Float) -> matrix_float4x4 {
	return simd_float4x4(diagonal: vector4(scale, scale, scale, 1.0))
}

// Create a translation matrix
func matrix_translation(t: SIMD3<Float>) -> matrix_float4x4 {
	return simd_float4x4(SIMD4<Float>(1.0,0.0,0.0,0.0), SIMD4<Float>(0.0,1.0,0.0,0.0), SIMD4<Float>(0.0,0.0,1.0,0.0), SIMD4<Float>(t.x,t.y,t.z,1.0))
}

// Create a model matrix with scaling, translation, and rotation
func matrix_model(scale: Float, t: SIMD3<Float>, angle: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
	return matrix_multiply(matrix_multiply(matrix_translation(t: t), matrix_rotation(angle: angle, axis: axis)), matrix_scaling(scale: scale))
}

// Create a model matrix with scaling and translation
func matrix_model(scale: Float, t: SIMD3<Float>) -> matrix_float4x4 {
	return matrix_multiply(matrix_translation(t: t), matrix_scaling(scale: scale))
}
