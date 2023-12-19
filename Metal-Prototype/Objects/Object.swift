//
//  Object.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit
import ModelIO

// Class representing a 3D object for rendering
class Object {
	
    // Object properties
	let name: String!
    var model = matrix_identity_float4x4
	private var parameters = ObjectConstants()
	private var material = MaterialConstants()
	
    // Buffers for GPU data
	private var vertexBuffer: MTLBuffer
	private var indexBuffer: MTLBuffer
	private var indexCount: Int
	
    // Initialization method
	init(name: String, device: MTLDevice, shininess: Int = 0) {
		self.name = name
		
        // Load the mesh from disk (Assumes existence of OBJ file)
		let url = Bundle.main.url(forResource: name, withExtension: "obj")
		let mesh = Mesh(url: url!)!
		
        // Process the mesh (center and normalize, compute tangent frame)
		mesh.centerAndUnit()
		mesh.computeTangentFrame()
		
        // Send mesh data to the GPU
		mesh.setupBuffers(device: device)
		vertexBuffer = mesh.vertexBuffer!
		indexBuffer = mesh.indexBuffer!
		indexCount = mesh.indexCount
		
		// Material setup and textures
		material.shininess = shininess
		loadTextures(device: device)
	}
	
    // Update method to compute transformations for the current frame
	func update(camera: Camera, vpLight: matrix_float4x4) {
		// Compute all transformations for this frame.
		parameters.mv = matrix_multiply(camera.viewMatrix, self.model)
		parameters.invmv = parameters.mv.inverse.transpose
		parameters.mvp = matrix_multiply(camera.projectionMatrix, parameters.mv)
		parameters.mvpLight = matrix_multiply(vpLight, self.model)
	}
	
    // Method to encode rendering commands for the object
	func encode(renderEncoder: MTLRenderCommandEncoder, constants: GlobalConstants) {
		renderEncoder.pushDebugGroup("Draw " + name)
		
		// Set buffers
		renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		
        // Uniforms for the vertex shader
		renderEncoder.setVertexBytes(&parameters, length: MemoryLayout<ObjectConstants>.stride, index: 1)
		
        // Uniforms for the fragment shader
		var localConstants = constants
		renderEncoder.setFragmentBytes(&localConstants, length: MemoryLayout<GlobalConstants>.stride, index: 0)
		renderEncoder.setFragmentBytes(&material, length: MemoryLayout<MaterialConstants>.stride, index: 1)
		
        // Textures
		setFragmentTextures(encoder: renderEncoder)
		
        // Draw
		renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
		
		renderEncoder.popDebugGroup()

	}
	
    // Method to encode shadow rendering commands
	func encodeShadow(renderEncoder: MTLRenderCommandEncoder) {
		renderEncoder.pushDebugGroup("Shadow " + name)
	
		// Set buffers
		renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		
        // Uniforms for the fragment shader
		renderEncoder.setVertexBytes(&parameters, length: MemoryLayout<ObjectConstants>.stride, index: 1)
		
        // Draw
		renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
		
		renderEncoder.popDebugGroup()

	}
	
    // Placeholder method for loading textures (to be overridden by subclasses)
	func loadTextures(device: MTLDevice) {
		// Has to be overriden by subclasses
		fatalError("Use a subclass implementing texture management.")
	}
	
    // Placeholder method for setting fragment textures (to be overridden by subclasses)
	func setFragmentTextures(encoder: MTLRenderCommandEncoder){
		// Has to be overriden by subclasses
		fatalError("Use a subclass implementing texture management.")
	}
}



