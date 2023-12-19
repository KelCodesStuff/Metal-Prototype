//
//  GameViewController.swift
//  3DSceneMetal
//
//  Created by Kel Reid on 08/10/2023
//

import Cocoa
import MetalKit
import simd

// Maximum number of command buffers in flight
let kMaxBuffers = 3

// Struct to hold parameters related to the Metal view
struct ViewParameters {
	let width: CGFloat
	let height: CGFloat
	let sampleCount: Int
	let colorPixelFormat: MTLPixelFormat
	let depthStencilPixelFormat: MTLPixelFormat
}

// Main view controller implementing the MetalKit delegate
class GameViewController: NSViewController, MTKViewDelegate {
	
	// GPU device
    private var device: MTLDevice! = nil
	
    // Global app command queue
    private var commandQueue: MTLCommandQueue! = nil
	
    // Semaphore for synchronization
    private let semaphore = DispatchSemaphore(value: kMaxBuffers)
    private var bufferIndex = 0
	
    // Renderer responsible for graphics rendering
	private var renderer: Renderer!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        // Setup the Metal view
        let view = self.view as! MTKView
		view.clearColor = MTLClearColorMake(1, 1, 1, 1) // Clear to solid white
		view.colorPixelFormat = .bgra8Unorm // Use a BGRA 8-bit normalized texture for the drawable
		view.depthStencilPixelFormat = .depth32Float // Use a 32-bit depth buffer
		
        // Get a reference to the GPU device
		device = MTLCreateSystemDefaultDevice()
		guard device != nil else {
			print("Metal is not supported on this device")
			self.view = NSView(frame: self.view.frame)
			return
		}
		
		// Create the command queue
		commandQueue = device.makeCommandQueue()
		
		// Store view setup parameters
		let viewParams = ViewParameters(width: view.frame.width, height: view.frame.height, sampleCount: view.sampleCount, colorPixelFormat: view.colorPixelFormat, depthStencilPixelFormat: view.depthStencilPixelFormat)
		
        // Create the renderer
		renderer = Renderer(device: device, parameters: viewParams)
		
        // Set this controller as the delegate for handling graphics updates
		view.delegate = self
		view.device = device
		
        // Disable color clearing thanks to the skybox (covering the full screen at any time)
		if let finalRenderDescriptor = view.currentRenderPassDescriptor {
			finalRenderDescriptor.colorAttachments[0].loadAction = .dontCare
		}
    }
    
    func draw(in view: MTKView) {
        // Use semaphore to encode 3 frames ahead
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
		
		// Time step (lazy)
		let step = 1.0 / TimeInterval((self.view as!MTKView).preferredFramesPerSecond)
		renderer.update(timeStep : step)
		
		// Create a command buffer
		guard let commandBuffer = commandQueue.makeCommandBuffer() else {
			print("Couldn't make command buffer")
			return
		}
        commandBuffer.label = "Frame command buffer"
        
        // Semaphore magic (signal when the command buffer has been processed by the GPU)
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.semaphore.signal()
            }
            return
        }
		
        // Get the final render pass descriptor (linked to the view) and the drawable
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
			// Register rendering commands
			renderer.encode(commandBuffer: commandBuffer, finalPass: renderPassDescriptor)
			
            // End of frame
			if let currentDrawable = view.currentDrawable {
				commandBuffer.present(currentDrawable)
			}
        }
		
		// Update commandBuffer index
        bufferIndex = (bufferIndex + 1) % kMaxBuffers
		// Commit commands, render!
        commandBuffer.commit()
		
    }
	
	
    // Pass resize event to the camera
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		renderer.camera.resize(width: size.width, height: size.height)
    }
	
	
	// Pass mouse events to the camera
	override func mouseDown(with event: NSEvent) {
		renderer.camera.startMove(point: event.locationInWindow)
	}
	
	override func mouseUp(with event: NSEvent) {
		renderer.camera.endMove()
	}
	
	override func mouseDragged(with event: NSEvent) {
		if(renderer.camera.isMoving){
			renderer.camera.move(point: event.locationInWindow)
		}
	}
	
	override func scrollWheel(with event: NSEvent) {
		renderer.camera.scroll(amount: event.scrollingDeltaY)
	}
	
}
