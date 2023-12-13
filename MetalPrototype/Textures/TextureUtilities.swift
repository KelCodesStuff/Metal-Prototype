//
//  TextureUtilities.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import MetalKit


// Simplify texture loading syntax.

extension MTKTextureLoader {
	
	func newTexture(withContentsOf url: URL, srgb: Bool)-> MTLTexture {
		return try! self.newTexture(URL: url,
		                            options: [
										MTKTextureLoader.Option.generateMipmaps: true,
										MTKTextureLoader.Option.allocateMipmaps: true,
										MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically,
										MTKTextureLoader.Option.SRGB : srgb
									])
	}
	
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
