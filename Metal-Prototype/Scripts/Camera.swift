//
//  Camera.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Foundation
import simd

// Camera class for handling camera transformations
class Camera {
	
    // View and projection matrices
	public var viewMatrix : matrix_float4x4
	public var projectionMatrix : matrix_float4x4
	public var isMoving = false
	private var clickPoint = NSPoint.zero
	
    // Camera parameters
	private var eye : SIMD3<Float>
	private var center : SIMD3<Float> = SIMD3<Float>(0.0,0.0,0.0)
	private var up : SIMD3<Float> = SIMD3<Float>(0.0,1.0,0.0)
	
	private var horizontalAngle : Float = 0.0
	private var verticalAngle : Float = 0.0
	private var radius : Float = 3.0
	private let speed : Float = 0.01
	
    // Initialize the camera with width and height
	init(width: CGFloat, height: CGFloat) {
		// Setup view matrix
		eye = radius*SIMD3<Float>(cos(verticalAngle)*cos(horizontalAngle), sin(verticalAngle), cos(verticalAngle)*sin(horizontalAngle))
		viewMatrix = lookAtMatrix(eye: eye, target: center, up: up)
		
        // Create projection matrix
		projectionMatrix = perspectiveMatrix(fov: 1.3, aspect: Float(width)/Float(height), near: 0.01, far: 100.0)
	}
	
    // Update the camera position and view matrix
	func update(step : TimeInterval) {
		// Update the camera postion, and the view matrix
		eye = radius*SIMD3<Float>(cos(verticalAngle)*cos(horizontalAngle), sin(verticalAngle), -cos(verticalAngle)*sin(horizontalAngle))
		viewMatrix = lookAtMatrix(eye: eye, target: center, up: up)
	}
	
    // Handle resize by updating the projection matrix
	func resize(width newWidth: CGFloat, height newHeight: CGFloat) {
		// Update projection matrix
		projectionMatrix = perspectiveMatrix(fov: 1.3, aspect: Float(newWidth)/Float(newHeight), near: 0.01, far: 100.0)
	}
	
	// Handle mouse interactions
    // Start moving the camera
	func startMove(point: NSPoint) {
		isMoving = true
		clickPoint = point
	}
	
    // Move the camera based on mouse movement
	func move(point: NSPoint) {
		let dx = Float(point.x - clickPoint.x)
		let dy = Float(point.y - clickPoint.y)
		horizontalAngle -= dx * speed
		verticalAngle -= dy * speed
		verticalAngle = min(max(verticalAngle, -1.57),1.57)
		clickPoint = point
	}
	
    // End camera movement
	func endMove() {
		isMoving = false
	}
	
    // Zoom in/out based on scroll amount
	func scroll(amount: CGFloat) {
		radius += speed*Float(amount)
		radius = min(max(0.01, radius), 8.0)
	}
	
}
