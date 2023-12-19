//
//  TextureUtilities.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit


// Simplify texture loading syntax for MTKTextureLoader
extension MTKTextureLoader {
	
    // Create a 2D texture from the contents of a URL with specified options
	func newTexture(withContentsOf url: URL, srgb: Bool)-> MTLTexture {
		return try! self.newTexture(URL: url,
		                            options: [
										MTKTextureLoader.Option.generateMipmaps: true,
										MTKTextureLoader.Option.allocateMipmaps: true,
										MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically,
										MTKTextureLoader.Option.SRGB : srgb
									])
	}
	
    // Create a cubemap texture from the contents of a URL with specified options
	func newTextureCubemap(withContentsOf url: URL, srgb: Bool)-> MTLTexture {
		return try! self.newTexture(URL: url,
		                            options: [
										MTKTextureLoader.Option.generateMipmaps: true,
										MTKTextureLoader.Option.allocateMipmaps: true,
										MTKTextureLoader.Option.origin : MTKTextureLoader.Origin.flippedVertically,
										MTKTextureLoader.Option.SRGB : srgb,
										MTKTextureLoader.Option.cubeLayout :  MTKTextureLoader.CubeLayout.vertical
									])
	}
	
}
