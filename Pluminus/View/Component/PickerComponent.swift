//
//  Picker.swift
//  Pluminus
//
//  Created by kimsangwoo on 7/7/24.
//

import SwiftUI

struct PickerComponent: View {
    @Binding var selectedPicker: [Int]
    @Binding var dataSource: [[String]]
    @Binding var pickerFastOrSlow: [String]
    @Binding var pickerHour: Int
    
    var body: some View {
        HStack {
            CustomPicker(dataSource: $dataSource, selectedPicker: $selectedPicker)
                .frame(width:160)
                .id(dataSource)
                .onChange(of: selectedPicker[0]) { oldValue, newValue in
                    print(">>>>> Picker OnChange [0] : \(selectedPicker[0])")
                    withAnimation {
                        pickerFastOrSlow = newValue == 0 ? ["ahead", "+"] : ["behind", "-"]
                        _ = hourRange
                        dataSource[1] = Array(hourRange).map { String($0) }
                        selectedPicker[1] = 0
                        _ = calcTargetLocalGMT(selectedPicker: selectedPicker)
                    }
                }
                .onChange(of: selectedPicker[1]) { oldValue, newValue in
                    HapticManager.instance.impact(style: .medium)
                    print(">>>>> Picker OnChange [1] : \(selectedPicker[1])")
                    withAnimation {
                        pickerHour = newValue
                        _ = hourRange
                        dataSource[1] = Array(hourRange).map { String($0) }
                        _ = calcTargetLocalGMT(selectedPicker: selectedPicker)
                    }
                }
                .onChange(of: dataSource) { oldValue, newValue in
                    HapticManager.instance.impact(style: .medium)
                    print("<<<<< Picker OnChange(dataSource)")
                    withAnimation {
                        _ = hourRange
                        dataSource[1] = Array(hourRange).map { String($0) }
                    }
                }
                .onAppear(perform: {
                    print("^^^^^ Picker OnAppear")
                    _ = calcTargetLocalGMT(selectedPicker: selectedPicker)
                    _ = hourRange
                    dataSource[1] = Array(hourRange).map { String($0) }
                })
                .onDisappear {
                    print("^^^^^ Picker OnDisappear")
                    _ = calcTargetLocalGMT(selectedPicker: selectedPicker)
                    _ = hourRange
                    dataSource[1] = Array(hourRange).map { String($0) }
                }
            
            Text("Hour")
                .font(.system(size: 17, weight: .bold))
        } //Picker
    } //body
    
    private var hourRange: ClosedRange<Int> {
        var wrappedGMT = calcCurrentLocalGMT() <= -11 ? -10 : calcCurrentLocalGMT()
        wrappedGMT = calcCurrentLocalGMT() >= 14 ? 13 : calcCurrentLocalGMT()
        
        if selectedPicker[0] == 0 {
            let min = 0
            let max = 14 - wrappedGMT
            
            return min...max
            
        } else {
            let min = 0
            let max = abs(-12 - wrappedGMT)
            
            return min...max
        }
    }
}
