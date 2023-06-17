//
//  ContentView.swift
//  Drawing
//
//  Created by Rishav Gupta on 14/06/23.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct Arc: InsettableShape {
    let startAngel: Angle
    let endAngle: Angle
    let clockwise: Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngel - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}
//saturation()
struct Flower: Shape {
    var petalOffset = -20.0
    var petalWidth = 100.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for number in stride(from: 0, through: Double.pi * 2, by: Double.pi / 8) {
            let rotation = CGAffineTransform(rotationAngle: number)
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width / 2))
            let rotatedPetal = originalPetal.applying(position)
            
            path.addPath(rotatedPetal)
        }
        
        return path
    }
}

struct ColorCyclingCicle: View {
    var amount = 0.0
    var steps: Int = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<steps, id: \.self) { value in
                Circle()
                    .inset(by:  Double(value))
                    .strokeBorder(
                        LinearGradient(gradient: Gradient(colors: [
                            color(for: value, brightness: 1),
                            color(for: value, brightness: 0.5),
                        ]), startPoint: .top, endPoint: .bottom),
                        lineWidth: 2
                    )
            }
        }
        .drawingGroup()
    }
    
    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount
        
        if targetHue > 1 {
            targetHue -= 1
        }
        
        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct Trapezoid: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
    }
}

struct CheckerBoard: Shape {
    var rows: Int
    var columns: Int
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(Double(rows), Double(columns)) }
        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)
        
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)
                    
                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }
        
        return path
    }
}

struct Arrow: Shape {
    var insetAmount: Double
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        path.move(to: CGPoint(x: rect.midX - 20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX - 70, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY - 100))
        path.addLine(to: CGPoint(x: rect.midX + 70, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + 20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + 20, y: rect.midY + 200))
        path.addLine(to: CGPoint(x: rect.midX - 20, y: rect.midY + 200))
        path.addLine(to: CGPoint(x: rect.midX - 20, y: rect.midY))
        
        return path
    }
}

struct ContentView: View {
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    
    @State private var colorCycle = 0.0
    
    @State private var amount = 0.0
    
    @State private var insetAmount = 50.0
    
    @State private var rows = 4
    @State private var columns = 4
    
    @State private var arrowThickness = 2.0
    
    var body: some View {
        VStack {
            Arrow(insetAmount: arrowThickness)
                .stroke(.red, style: StrokeStyle(lineWidth: arrowThickness, lineCap: .round, lineJoin: .round))
                .frame(width: 300, height: 300)
            Spacer()
            Slider(value: $arrowThickness, in: 2...20)
                .padding()
        }
        
        
//        CheckerBoard(rows: rows, columns: columns)
//            .onTapGesture {
//                withAnimation(.linear(duration: 3)) {
//                    rows = 8
//                    columns = 16
//                }
//            }
        
        
//        Trapezoid(insetAmount: insetAmount)
//            .frame(width: 200 ,height: 100)
//            .onTapGesture {
//                withAnimation {
//                    insetAmount = Double.random(in: 10...90)
//                }
//            }
        
        
//        VStack {
////            ZStack {
////                Circle()
////                    .fill(.red)
////                    .frame(width: 200 * amount)
////                    .offset(x: -50, y: -80)
////                    .blendMode(.screen)
////
////                Circle()
////                    .fill(.green)
////                    .frame(width: 200 * amount)
////                    .offset(x: 50, y: -80)
////                    .blendMode(.screen)
////
////                Circle()
////                    .fill(.blue)
////                    .frame(width: 200 * amount)
////                    .blendMode(.screen)
////            }
////            .frame(width: 300, height: 300)
//
//            Image("PaulHudson")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200, height: 200)
////                .saturation(amount)
//                .blur(radius: (1 - amount) * 20)
//
//            Slider(value: $amount)
//                .padding()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.black)
//        .ignoresSafeArea()
        
        
//        ZStack {
//            Image("PaulHudson")
//                .colorMultiply(.red)
            
//            Rectangle()
//                .fill(.red)
//                .blendMode(.multiply)
//        }
        
        
//        VStack {
//            ColorCyclingCicle(amount: colorCycle)
//                .frame(width: 300, height: 300)
//
//            Slider(value: $colorCycle)
//        }
        
        
//        Text("Hello World")
//            .frame(width: 300, height: 300)
//            .border(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0.4, width: 1, height: 0.2), scale: 0.2), width: 50)
        
//        Capsule()
////            .border(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0.4, width: 1, height: 0.2), scale: 0.2), width: 20)
//            .strokeBorder(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0.4, width: 1, height: 0.2), scale: 0.2), lineWidth: 20)
//            .frame(width: 300, height: 200)
        
        
//        VStack {
//            Flower(petalOffset: petalOffset, petalWidth: petalWidth)
//                .stroke(.red, lineWidth: 1)
////                .fill(.red, style: .init(eoFill: true))
//
//            Text("Offser")
//            Slider(value: $petalOffset, in: -40...40)
//                .padding([.horizontal, .bottom])
//
//            Text("Width")
//            Slider(value: $petalWidth, in: 0...100)
//                .padding(.horizontal)
//        }
        
//        Arc(startAngel: .degrees(-90), endAngle: .degrees(90), clockwise: true)
//            .strokeBorder(.blue, lineWidth: 40)
        
        
//        Arc(startAngel: .degrees(0), endAngle: .degrees(110), clockwise: true)
//            .stroke(.blue, style: StrokeStyle(lineWidth: 10))
//            .frame(width: 300, height: 300)
        
        
//        Triangle()
////            .fill(.red)
//            .stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
//            .frame(width: 300, height: 300)
        
        
//        Path { path in
//            path.move(to: CGPoint(x: 200, y: 100))
//            path.addLine(to: CGPoint(x: 100, y: 300))
//            path.addLine(to: CGPoint(x: 300, y: 300))
//            path.addLine(to: CGPoint(x: 200, y: 100))
//            path.closeSubpath()
//        }
//        .fill(.blue)
//        .stroke(.blue, lineWidth: 10)
//        .stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
