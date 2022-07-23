//
//  ContentView.swift
//  pivot
//
//  Created by Wipawe Sirikolkarn on 7/14/22.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Metal

struct ContentView : View {
    
    @State private var count = -1
    
    var body: some View {
        ZStack() {
            ARViewContainer(count: $count)
            randomEncouragement(count: count)
        }
        .ignoresSafeArea()
    }
}

struct ARViewContainer: UIViewRepresentable {

    @Binding var count: Int

    func makeUIView(context: Context) -> ARView {

        let arView = ARView()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config)

        //add coaching
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)

        //handle session
        context.coordinator.view = arView
        arView.session.delegate = context.coordinator

        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        return arView

    }

    func updateUIView(_ uiView: ARView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var focusEntity: FocusEntity?
        var box: ModelEntity?
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else { return }
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .clear))
            parent.count = 0
        }
        
        @objc func handleTap() {
            guard let view = self.view, let focusEntity = self.focusEntity else { return }
            
            if let box = self.box {
                var rotationTransform = box.transform
                rotationTransform.rotation = simd_quatf(angle: Float.random(in: 0.0...360.0) * Float.pi / 180.0, axis: [0.1,1,0])
                box.move(to: rotationTransform, relativeTo: box.parent, duration: 0.5, timingFunction: .easeInOut)
                
                parent.count = Int.random(in: 1...12)
                
            } else {
                let anchor = AnchorEntity()
                view.scene.anchors.append(anchor);
                
                let box = try! ModelEntity.loadModel(named: "pointer")
                box.scale = [0.015, 0.015, 0.015]
                
                let boxMat = SimpleMaterial(color: .green, isMetallic: false)
                box.model?.materials = [boxMat]
                
                let device = MTLCreateSystemDefaultDevice()
                guard let defaultLibrary = device!.makeDefaultLibrary()
                else {return}
                
                let surfaceShader = CustomMaterial.SurfaceShader(
                    named: "surfaceShader", in: defaultLibrary
                )

                box.model?.materials = box.model?.materials.map {
                  try! CustomMaterial(from: $0, surfaceShader: surfaceShader)
                } ?? [boxMat]

                box.position = focusEntity.position
                self.box = box
                anchor.addChild(box)
            }
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

