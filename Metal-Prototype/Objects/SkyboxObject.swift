//
//  SkyboxObject.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit

// Subclass of Object, representing a skybox in a 3D scene
class SkyboxObject : Object {
	
    // Texture property for the skybox
	private var textureColor: MTLTexture!
	
    // Override the method to load the skybox texture
	override func loadTextures(device: MTLDevice) {
        // Only one texture is expected for the skybox, representing a cubemap with faces stacked vertically
		let urlTexColor = Bundle.main.url(forResource: name, withExtension: ".png")!
		let textureLoader = MTKTextureLoader(device: device)
		
        // Load the cubemap texture and store it as an instance variable
        textureColor = textureLoader.newTextureCubemap(withContentsOf: urlTexColor, srgb: false)
	}
	
    // Override the method to set the fragment texture during rendering
	override func setFragmentTextures(encoder: MTLRenderCommandEncoder) {
        // Set the skybox texture to a specific fragment index
		encoder.setFragmentTexture(textureColor, index: 0)
	}
	
}
