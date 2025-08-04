//
//  SunburstView.swift
//  SunburstDiagram
//
//  Created by Ludovic Landry on 6/10/19.
//  Copyright © 2019 Ludovic Landry. All rights reserved.
//

import SwiftUI

public struct SunburstView: View {

    @ObservedObject var sunburst: Sunburst
    
    public init(configuration: SunburstConfiguration) {
        sunburst = configuration.sunburst
    }
    
    public var body: some View {
        let arcs = ZStack {
            configureViews(arcs: sunburst.rootArcs)
            
            // Stop the window shrinking to zero when there is no arcs.
            Spacer()
        }
        .flipsForRightToLeftLayoutDirection(true)
        .padding()

        let drawnArcs = arcs.drawingGroup()
        return drawnArcs
    }
    
    private func configureViews(arcs: [Sunburst.Arc], parentArc: Sunburst.Arc? = nil) -> some View {
        return ForEach(arcs) { arc in
            ArcView(arc: arc, configuration: self.sunburst.configuration).onTapGesture {
                guard self.sunburst.configuration.allowsSelection else { return }
                if self.sunburst.configuration.selectedNode == arc.node && self.sunburst.configuration.focusedNode == arc.node {
                    self.sunburst.configuration.focusedNode = self.sunburst.configuration.parentForNode(arc.node)
                } else if self.sunburst.configuration.selectedNode == arc.node {
                    self.sunburst.configuration.focusedNode = arc.node
                } else {
                    self.sunburst.configuration.selectedNode = arc.node
                }
            }
            IfLet(arc.childArcs) { childArcs in
                AnyView(self.configureViews(arcs: childArcs, parentArc: arc))
            }
        }
    }
}

#if DEBUG
struct SunburstView_Previews: PreviewProvider {
    static var previews: some View {
        // Layer 3 nodes
        let fileNodes1 = [
            Node(name: "File 1", value: 5.0, backgroundColor: .systemGreen),
            Node(name: "File 2", value: 10.0, backgroundColor: .systemGreen)
        ]
        let fileNodes2 = [
            Node(name: "File 3", value: 3.0, backgroundColor: .systemOrange),
            Node(name: "File 4", value: 7.0, backgroundColor: .systemOrange)
        ]

        // Layer 2 nodes with children
        let folderNodes = [
            Node(name: "Documents", value: nil, backgroundColor: .systemBlue, children: fileNodes1),
            Node(name: "Downloads", value: nil, backgroundColor: .systemPurple, children: fileNodes2)
        ]

        // Layer 1 root nodes with children
        let rootNodes = [
            Node(name: "User", value: nil, backgroundColor: .systemRed, children: folderNodes),
            Node(name: "System", value: 20.0, backgroundColor: .systemGray)
        ]

        let configuration = SunburstConfiguration(nodes: rootNodes, calculationMode: .parentIndependent())

        return SunburstView(configuration: configuration)
    }
}
#endif
