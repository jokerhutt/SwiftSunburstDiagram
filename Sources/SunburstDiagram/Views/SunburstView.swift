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
        let configuration = SunburstConfiguration(nodes: testNodes, calculationMode: .parentIndependent())
        return SunburstView(configuration: configuration)
            .frame(width: 1200, height: 1000)  // Adjust these values as needed
    }
}
#endif

let rootColor = NSColor.systemGray  // Root circle is gray now

let baseChildColor = NSColor.systemRed

let testNodes = [
    Node(
        name: "",
        value: nil,
        backgroundColor: rootColor,  // root is gray
        children: [
            createNodesTree(depth: 0, maxDepth: 7, maxChildren: 2, baseColor: baseChildColor),                   // independent base colors for children
            createNodesTree(depth: 0, maxDepth: 5, maxChildren: 3, baseColor: baseChildColor.rotatedHue(by: 0.12)),
            createNodesTree(depth: 0, maxDepth: 6, maxChildren: 2, baseColor: baseChildColor.rotatedHue(by: 0.24)),
            createNodesTree(depth: 0, maxDepth: 8, maxChildren: 1, baseColor: baseChildColor.rotatedHue(by: 0.36)),
            createNodesTree(depth: 0, maxDepth: 4, maxChildren: 3, baseColor: baseChildColor.rotatedHue(by: 0.48))
        ]
    ),
    Node(name: "", value: 15.0, backgroundColor: .systemGray)
]
func createNodesTree(
    name: String = "",
    depth: Int,
    maxDepth: Int,
    maxChildren: Int,
    baseColor: NSColor
) -> Node {
    if depth >= maxDepth {
        let value = Double.random(in: 1...10)
        return Node(name: "", value: value, backgroundColor: baseColor)
    }
    
    let childrenCount = Int.random(in: 1...maxChildren)
    var children: [Node] = []
    
    for i in 0..<childrenCount {
        let siblingHueShift = CGFloat(i) * 0.02
        let lightenedColor = baseColor.lighter(by: CGFloat(depth) * 0.01)
        let childColor = lightenedColor.rotatedHue(by: siblingHueShift)
        
        let childNode = createNodesTree(
            name: "", // empty name for children as well
            depth: depth + 1,
            maxDepth: maxDepth,
            maxChildren: maxChildren,
            baseColor: childColor
        )
        children.append(childNode)
    }
    
    return Node(name: name, value: nil, backgroundColor: baseColor, children: children)
}
