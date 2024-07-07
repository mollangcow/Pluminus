//
//  TimeGapVisualGraphComponent.swift
//  Pluminus
//
//  Created by kimsangwoo on 7/7/24.
//

import SwiftUI

struct TimeGapVisualGraphComponent: View {
    @State private var rectangleHeight: CGFloat = 1
    
    @Binding var pickerFastOrSlow: [String]
    @Binding var pickerHour: Int
    
    var body: some View {
        HStack {
            VStack {
                HStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        .white.opacity(0),
                                        .white.opacity(1)
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2, height: rectangleHeight)
                        .padding(.leading, 20)
                        .onAppear {
                            withAnimation(.spring(duration: 1.0)) {
                                rectangleHeight = calcTimeGapStrokeHeight(pickerHour: pickerHour)
                            }
                        }
                        .onDisappear {
                            rectangleHeight = 1
                        }
                    
                    Text("\(pickerFastOrSlow[1]) \(pickerHour)Hour")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(height: screenHeight * 0.18)
    } //body
    
    func calcTimeGapStrokeHeight(pickerHour: Int) -> CGFloat {
        let minHeight: CGFloat = screenHeight * 0.02
        let maxHeight: CGFloat = screenHeight * 0.2
        let hourRange: ClosedRange<Int> = 0...27
        
        let normalizedHour = CGFloat(pickerHour - hourRange.lowerBound) / CGFloat(hourRange.upperBound - hourRange.lowerBound)
        
        let calculatedHeight = minHeight + (maxHeight - minHeight) * normalizedHour
        
        return calculatedHeight
    }
} //struct
