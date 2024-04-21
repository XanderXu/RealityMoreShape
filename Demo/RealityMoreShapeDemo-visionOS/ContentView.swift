//
//  ContentView.swift
//  RealityMoreShapeDemo-visionOS
//
//  Created by xu on 2024/4/19.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var model = ViewModel()
    @State private var selectedIndex: Int = 0
    @State private var visualizationIndex: Int = 1
    
    var body: some View {
        NavigationSplitView {
            List(0..<18) { index in
                Button(action: {
                    selectedIndex = index
                }, label: {
                    Text(model.meshNames[index])
                })
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .background(Color.clear)
                        .foregroundColor((index == selectedIndex) ? Color.teal.opacity(0.3) : .clear)
                )
                
            }
            .navigationTitle("Reality More Shap Demo")
        } detail: {
            VStack {
                Picker("Visualization", selection: $visualizationIndex) {
                    Text("None").tag(1)
                    Text("Nomal").tag(2)
                    Text("UV").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 450)
                
                RealityView { content in
                    var m = PhysicallyBasedMaterial()
                    let texture = try! await TextureResource.init(named: "number.jpeg")
                    m.baseColor = .init(tint: .white, texture:.init(texture))
                    var m2 = PhysicallyBasedMaterial()
                    m2.baseColor = .init(tint: .red, texture: nil)
                    
                    
                    if let mesh = model.generateShapeOfIndex(selectedIndex) {
                        let model = ModelEntity(mesh:mesh, materials: [m,m,m2])
                        model.name = "model"
                        content.add(model)
                    }
                    
                } update: { content in
                    debugPrint("update")
                    if let mesh = model.generateShapeOfIndex(selectedIndex) {
                        let model = content.entities.first { e in
                            e.name == "model"
                        } as? ModelEntity
                        
                        model?.model?.mesh = mesh
                        
                        model?.components.remove(ModelDebugOptionsComponent.self)
                        switch visualizationIndex {
                        case 1:
                            break
                        case 2:
                            let debug = ModelDebugOptionsComponent(visualizationMode: .normal)
                            model?.components.set(debug)
                        case 3:
                            let debug = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
                            model?.components.set(debug)
                        default:
                            break
                        }
                    }
                }
                
                
            }
            .navigationTitle(model.meshNamesLocal[selectedIndex])
        }
        .frame(minWidth: 800, minHeight: 500)
        
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
