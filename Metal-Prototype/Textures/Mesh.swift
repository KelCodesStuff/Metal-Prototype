//
//  Mesh.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import simd
import MetalKit

// Represents a set of face indices (vertex, texture coordinate, normal)
struct FaceIndices : Hashable, Equatable {
	var v : Int
	var t : Int
	var n : Int
    
    // Hashing for conforming to Hashable protocol
	var hashValue : Int {
		return "\(v),\(t),\(n)".hash
	}
}

// Equatability for conforming to Equatable protocol
func ==(lhs: FaceIndices, rhs: FaceIndices) -> Bool {
	return (lhs.v == rhs.v && lhs.n == rhs.n && lhs.t == rhs.t)
}

// Represents a 3D vertex with position, normal, tangent, bitangent, and texture coordinates
struct Vertex {
	var position = SIMD3<Float>(0.0,0.0,0.0)
	var normal = SIMD3<Float>(0.0,0.0,0.0)
	var tangent = SIMD3<Float>(0.0,0.0,0.0)
	var bitangent = SIMD3<Float>(0.0,0.0,0.0)
	var texcoords = SIMD2<Float>(0.0,0.0)
}

// Represents a 3D mesh with vertices, indices, and Metal buffers
class Mesh {
	private var vertices : [Vertex] = []
	private var indices : [uint32] = []
    
    // Metal buffers
	public var vertexBuffer : MTLBuffer? = nil
	public var indexBuffer : MTLBuffer? = nil
	
    // Computed property for the number of indices
    public var indexCount : Int {
		get {
			return indices.count
		}
	}
	
    // Initializes the mesh from an OBJ file at the given URL
	init?(url : URL) {
        // Parsing OBJ file and populating vertex and index data
		guard let stringContent = try? String(contentsOf: url) else {
			print("Error")
			return nil
		}
		let lines = stringContent.components(separatedBy: CharacterSet.newlines)
		
		var positions : [SIMD3<Float>] = []
		var normals : [SIMD3<Float>] = []
		var uvs : [SIMD2<Float>] = []
		var faces : [FaceIndices] = []
		
		for line in lines {
			if (line.hasPrefix("v ")){//Vertex
				let components = line.components(separatedBy: CharacterSet.whitespaces)
				positions.append( SIMD3<Float>( Float(components[1])!, Float(components[2])!, Float(components[3])! ) )
			} else if (line.hasPrefix("vt ")) {//UV coords
				let components = line.components(separatedBy: CharacterSet.whitespaces)
				uvs.append( SIMD2<Float>( Float(components[1])!, Float(components[2])! ) )
				
			} else if (line.hasPrefix("vn ")) {//Normal coords
				let components = line.components(separatedBy: CharacterSet.whitespaces)
				normals.append( SIMD3<Float>( Float(components[1])!, Float(components[2])!, Float(components[3])! ) )
			} else if (line.hasPrefix("f ")) {//Face with vertices/uv/normals
				let components = line.components(separatedBy: CharacterSet.whitespaces)
				// Split each face 3 indices
				let splittedComponents = components.map({$0.components(separatedBy: "/")})
				
				for i in 1..<4 {
					let intComps = splittedComponents[i].map({ comp -> Int in
						return comp == "" ? 0 : Int(comp)!
						})
					faces.append(FaceIndices(v: intComps[0], t: intComps[1], n: intComps[2]))
				}
			}
		}
		
		if positions.isEmpty || faces.isEmpty || faces[0].v == 0 {
			print("Missing data")
			return nil
		}
			
		
		var facesDone : [FaceIndices : uint32] = [:]
		var currentIndex : uint32 = 0
		
		for faceItem in faces {
			if let indice = facesDone[faceItem]{
				indices.append(indice)
			} else {
				//New
				var vertex = Vertex()
				vertex.position = positions[faceItem.v - 1]
				
				if(faceItem.t > 0){
					vertex.texcoords = uvs[faceItem.t - 1]
				}
				
				if(faceItem.n > 0){
					vertex.normal = normals[faceItem.n - 1]
				}
				
				vertices.append(vertex)
				
				
				indices.append(currentIndex)
				facesDone[faceItem] = currentIndex
				currentIndex += 1
			}
		}
		print("OBJ: loaded. \(indices.count/3) faces, \(positions.count) vertices, \(normals.count) normals, \(uvs.count) texcoords.")
	}
	
    // Centers and scales the mesh to fit within a unit cube
	public func centerAndUnit() {
        // Translation and scaling logic to center and fit the mesh within a unit cube
		var centroid = SIMD3<Float>(0.0,0.0,0.0)
		
		for i in 0..<vertices.count {
			centroid += vertices[i].position;
		}
		
		centroid *= (1.0/Float(vertices.count))
		
		var maxi = vertices[0].position.x;
		for i in 0..<vertices.count {
			
			vertices[i].position -= centroid
			
			maxi = abs(vertices[i].position.x) > maxi ? abs(vertices[i].position.x) : maxi;
			maxi = abs(vertices[i].position.y) > maxi ? abs(vertices[i].position.y) : maxi;
			maxi = abs(vertices[i].position.z) > maxi ? abs(vertices[i].position.z) : maxi;
		}
		
		maxi = (maxi == 0.0 ? 1.0 : maxi)
		
		// Scale the mesh
		for i in 0..<vertices.count {
			vertices[i].position *= (1.0/maxi)
		}
	}
	
    // Computes the tangent and bitangent for each vertex in the mesh
	public func computeTangentFrame() {
        // Tangent frame computation logic for normal mapping
		if indices.isEmpty || vertices.isEmpty {
			return;
		}
		
		// Then, compute both vectors for each face and accumulate them
		for face in 0..<(indices.count/3) {
			let v0 = vertices[Int(indices[3*face  ])]
			let v1 = vertices[Int(indices[3*face+1])]
			let v2 = vertices[Int(indices[3*face+2])]
			
			
			// Delta positions and uvs
			let deltaPosition1 = v1.position - v0.position
			let deltaPosition2 = v2.position - v0.position
			let deltaUv1 = v1.texcoords - v0.texcoords
			let deltaUv2 = v2.texcoords - v0.texcoords
			
			// Compute tangent and binormal for the face
			let det = 1.0 / (deltaUv1.x * deltaUv2.y - deltaUv1.y * deltaUv2.x)
			let tangent = det * (deltaPosition1 * deltaUv2.y   - deltaPosition2 * deltaUv1.y)
			let bitangent = det * (deltaPosition2 * deltaUv1.x   - deltaPosition1 * deltaUv2.x)
			
			// Accumulate them. We don't normalize to get a free weighting based on the size of the face
			vertices[Int(indices[3*face  ])].tangent += tangent
			vertices[Int(indices[3*face+1])].tangent += tangent
			vertices[Int(indices[3*face+2])].tangent += tangent
			
			vertices[Int(indices[3*face  ])].bitangent += bitangent
			vertices[Int(indices[3*face+1])].bitangent += bitangent
			vertices[Int(indices[3*face+2])].bitangent += bitangent
		}
		// Finally, enforce orthogonality and good orientation of the basis
		for i in 0..<vertices.count {
			vertices[i].tangent = normalize(vertices[i].tangent - vertices[i].normal * dot(vertices[i].normal, vertices[i].tangent))
			if dot(cross(vertices[i].normal, vertices[i].tangent), vertices[i].bitangent) < 0.0 {
				vertices[i].tangent *= -1.0
			}
			vertices[i].bitangent = normalize(vertices[i].bitangent)
		}

	}
	
    // Sets up Metal buffers for the vertices and indices
	public func setupBuffers(device : MTLDevice) {
        // Creating Metal buffers for vertices and indices
		vertexBuffer = device.makeBuffer(bytes: &vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
		indexBuffer = device.makeBuffer(bytes: &indices, length: indices.count * MemoryLayout<uint32>.stride, options: [])
	}
}






