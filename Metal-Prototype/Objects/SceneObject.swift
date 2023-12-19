//
//  SceneObject.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit

// Subclass of Object, representing a 3D object in a scene with additional texture functionality
class SceneObject : Object {

    // Texture properties
	private var textureColor: MTLTexture!
	private var textureNormal: MTLTexture!
	private var shadowMap: MTLTexture!
	
    // Initialization method
	init(name: String, device: MTLDevice, shininess: Int, shadowMap: MTLTexture) {
        // Call the superclass initializer
		super.init(name: name, device: device, shininess: shininess)
		
        // Store the sahdow map
		self.shadowMap = shadowMap
	}
	
    // Override the texture loading method to load color and normal textures
	override func loadTextures(device: MTLDevice) {
        // Use MTKTextureLoader to load color and normal textures from PNG files
		let textureLoader = MTKTextureLoader(device: device)
		
        // Construct URLs based on the object's name
		let urlTexColor = Bundle.main.url(forResource: name + "_texture_color", withExtension: ".png")!
		let urlTexNormal = Bundle.main.url(forResource: name + "_texture_normal", withExtension: ".png")!
        
        // Load textures and store them as instance variables
		textureColor = textureLoader.newTexture(withContentsOf: urlTexColor, srgb: false)
		textureNormal = textureLoader.newTexture(withContentsOf: urlTexNormal, srgb: false)
	}
	
    // Override the method to set fragment textures during rendering
	override func setFragmentTextures(encoder: MTLRenderCommandEncoder) {
        // Set color, normal, and shadow map textures to specific fragment indices
		encoder.setFragmentTexture(textureColor, index: 0)
		encoder.setFragmentTexture(textureNormal, index: 1)
		encoder.setFragmentTexture(shadowMap, index: 2)
	}
	
}
