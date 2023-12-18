//
//  SkyboxObject.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit

class SkyboxObject : Object {
	
	private var textureColor: MTLTexture!
	
	override func loadTextures(device: MTLDevice) {
		// Only one texture, the cubemap. Faces are stacked vertically.
		let urlTexColor = Bundle.main.url(forResource: name, withExtension: ".png")!
		let textureLoader = MTKTextureLoader(device: device)
		textureColor = textureLoader.newTextureCubemap(withContentsOf: urlTexColor, srgb: false)
	}
	
	override func setFragmentTextures(encoder: MTLRenderCommandEncoder) {
		encoder.setFragmentTexture(textureColor, index: 0)
	}
	
}
