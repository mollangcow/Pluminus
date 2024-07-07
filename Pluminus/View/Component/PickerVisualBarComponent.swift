//
//  PickerVisualBarComponent.swift
//  Pluminus
//
//  Created by kimsangwoo on 7/7/24.
//

import SwiftUI

struct PickerVisualBarComponent: View {
    @State private var spacerWidth: CGFloat = 0
    
    @Binding var selectedPicker: [Int]
    @Binding var pickerFastOrSlow: [String]
    @Binding var pickerHour: Int
    
    var body: some View {
        VStack {
            ZStack {
                //GMT Bar
                HStack {
                    Text("GMT-12")
                        .font(.system(size: 7, weight: .regular))
                    
                    Rectangle()
                        .frame(width: 260, height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("GMT+14")
                        .font(.system(size: 7, weight: .regular))
                } //HStack
                
                //Base GMT Mark
                HStack {
                    Spacer()
                        .frame(width: pickerVisualStaticSpacer())
                    
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: 2, height: 10)
                        .foregroundColor(.primary.opacity(0.3))
                    
                    Spacer()
                } //HStack
                .frame(width: 260)
                
                //Target GMT Mark
                HStack {
                    Spacer()
                        .frame(width: spacerWidth)
                        .onAppear {
                            withAnimation {
                                self.spacerWidth = pickerVisualMovingSpacer()
                            }
                        }
                        .onChange(of: selectedPicker) { oldValue, newValue in
                            if oldValue != newValue {
                                withAnimation {
                                    self.spacerWidth = pickerVisualMovingSpacer()
                                }
                            }
                        }
                    
                    RoundedRectangle(cornerRadius: 1)
                        .frame(width: 2, height: 10)
                        .foregroundColor(.primary)
                    
                    Spacer()
                } //HStack
                .frame(width: 260)
            } //ZStack
            
            if pickerHour == 0  {
                Text("Same time zone as base")
                    .font(.system(size: 14, weight: .regular))
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .contentTransition(.numericText())
            } else {
                Text("\(pickerHour)hours \(pickerFastOrSlow[0]) of base")
                    .font(.system(size: 14, weight: .regular))
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .contentTransition(.numericText())
            }
        }
    } //body
    
    func pickerVisualMovingSpacer() -> CGFloat {
        let hour = calcTargetLocalGMT(selectedPicker: selectedPicker)
        
        if hour == -12 {
            return 0
        } else if hour == 0 {
            return 130
        } else if hour >= -11 && hour <= 14 {
            return CGFloat(hour + 12) * 10
        }
        
        return 0
    }
    
    func pickerVisualStaticSpacer() -> CGFloat {
        let hour = calcCurrentLocalGMT()
        
        if hour == -12 {
            return 0
        } else if hour == 0 {
            return 130
        } else if hour >= -11 && hour <= 14 {
            return CGFloat(hour + 12) * 10
        }
        
        return 0
    }
} //struct
