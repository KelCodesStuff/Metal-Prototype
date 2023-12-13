//
//  SceneObject.swift
//  3DSceneMetal
//
//  //  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit


class SceneObject : Object {

	private var textureColor: MTLTexture!
	private var textureNormal: MTLTexture!
	private var shadowMap: MTLTexture!
	
	init(name: String, device: MTLDevice, shininess: Int, shadowMap: MTLTexture) {
		super.init(name: name, device: device, shininess: shininess)
		// Store the sahdow map.
		self.shadowMap = shadowMap
	}
	
	override func loadTextures(device: MTLDevice) {
		let textureLoader = MTKTextureLoader(device: device)
		// Two textures: color and normals.
		let urlTexColor = Bundle.main.url(forResource: name + "_texture_color", withExtension: ".png")!
		let urlTexNormal = Bundle.main.url(forResource: name + "_texture_normal", withExtension: ".png")!
		textureColor = textureLoader.newTexture(withContentsOf: urlTexColor, srgb: false)
		textureNormal = textureLoader.newTexture(withContentsOf: urlTexNormal, srgb: false)
	}
	
	override func setFragmentTextures(encoder: MTLRenderCommandEncoder) {
		encoder.setFragmentTexture(textureColor, index: 0)
		encoder.setFragmentTexture(textureNormal, index: 1)
		encoder.setFragmentTexture(shadowMap, index: 2)
	}
	
}
