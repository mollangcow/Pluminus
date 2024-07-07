//
//  MainView.swift
//  NC1
//  Created by kimsangwoo on 2023/06/01.
//
//

import CoreLocation
import SwiftUI
import WrappingHStack

struct MainView: View {
    @StateObject var locationManager = MyLocationManager()
    
    @Namespace private var animation
    
    @State var isLaunching: Bool = true
    
    @State private var currentLocalName: String = ""
    @State private var selectedPicker: [Int] = [0, 0]
    @State private var isShowingResult: Bool = false
    @State private var isShowingSettingView: Bool = false
    
    @State private var isShowingCLMapView: Bool = false
    @State private var savedLocation: CLLocationCoordinate2D?
    @State private var cLName = "Unknown"
    @State private var tzOffset = 0
    
    @State private var currentTimeAString: String = ""
    @State private var currentTimeHMMSSString: String = ""
    @State private var currentDateStirng: String = ""
    
    @State private var dataSource: [[String]] = [["+","-"], []]
    @State private var pickerFastOrSlow: [String] = ["ahead", "+"]
    @State private var pickerHour: Int = 0
    
    @State private var expandedCountry: Country? = nil
    @State private var hiddenCountryIndices: Set<Int> = []
    @State private var offset: CGFloat = .zero
    @State private var isShowingMap: Bool = false
    @State private var tappedCountry: String = ""
    @State private var tappedContinent: String = ""
    
    private let threshold: CGFloat = 100
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                //BaseTime Section
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(currentTimeAString)
                            .font(.system(size: isShowingResult ? 32 : 72, weight: isShowingResult ? .thin : .heavy))
                            .foregroundStyle(isShowingResult ? Color.white : Color.primary)
                            .contentTransition(.numericText())
                        
                        Text(currentTimeHMMSSString)
                            .font(.system(size: 72, weight: isShowingResult ? .thin : .heavy))
                            .foregroundStyle(isShowingResult ? Color.white : Color.primary)
                            .contentTransition(.numericText())
                        
                        Text(currentDateStirng)
                            .font(.system(size: 20, weight: isShowingResult ? .light : .bold))
                            .foregroundStyle(isShowingResult ? Color.white : Color.primary)
                            .contentTransition(.numericText())
                    } // VStack
                    
                    Spacer()
                    
                    //Setting Button
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(isShowingResult ? Color.clear : Color.gray.opacity(0.4))
                        .padding(.top, 12)
                        .onTapGesture {
                            HapticManager.instance.impact(style: .light)
                            isShowingSettingView = true
                        }
                        .disabled(isShowingResult == true)
                } //HStack
                .padding(.top, 12)
                
                //BaseLocation Section
                HStack {
                    Spacer()
                    
                    Image("locationPin")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 15, height: 19)
                        .foregroundStyle(isShowingResult ? Color.white : Color.orange)
                    Text(currentLocalName)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(isShowingResult ? Color.white : Color.primary)
                        .onTapGesture {
                            HapticManager.instance.impact(style: .rigid)
                            isShowingCLMapView = true
                        }
                        .disabled(isShowingResult == true)
                } // HStack
                .padding(.top, 8)
                
                if isShowingResult == false {
                    Spacer()
                    
                    PickerComponent(
                        selectedPicker: $selectedPicker,
                        dataSource: $dataSource,
                        pickerFastOrSlow: $pickerFastOrSlow,
                        pickerHour: $pickerHour
                    )
                    
                    Spacer()
                    
                    PickerVisualBarComponent(
                        selectedPicker: $selectedPicker,
                        pickerFastOrSlow: $pickerFastOrSlow,
                        pickerHour: $pickerHour
                    )
                } else {
                    TimeGapVisualGraphComponent(
                        pickerFastOrSlow: $pickerFastOrSlow,
                        pickerHour: $pickerHour
                    )
                    
                    // Target Time
                    HStack(alignment: .bottom) {
                        Text(Date().currentLocalTime(tzOffset: selectPickerResult(selectedPicker: selectedPicker)))
                            .font(.system(size: 64, weight: .heavy))
                            .foregroundStyle(Color.white)
                        
                        Text("GMT\(showingTargetLocalGMT(selectedPicker: selectedPicker))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding(.bottom, 16)
                        
                        Spacer()
                    }
                    // Target Date
                    HStack {
                        Text(Date().currentLocalDate(tzOffset: selectPickerResult(selectedPicker: selectedPicker)))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .padding(.leading, 4)
                        
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
                    WrappedIndexingCountryComponent(
                        animation: animation,
                        expandedCountry: $expandedCountry,
                        hiddenCountryIndices: $hiddenCountryIndices,
                        tappedCountry: $tappedCountry,
                        tappedContinent: $tappedContinent,
                        selectedPicker: $selectedPicker
                    )
                } //else
                
                //TimeGap Search Button
                Button {
                    HapticManager.instance.notification(type: .warning)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring) {
                            isShowingResult.toggle()
                        }
                    }
                } label: {
                    Image(systemName: "arrow.forward")
                        .rotationEffect(.degrees(isShowingResult ? 180 : 0)) // 회전 효과 추가
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .black))
                        .frame(maxWidth: 500, maxHeight: 70)
                        .background(isShowingResult ? Color.black : Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                } // Button
                .padding(.horizontal, isShowingResult ? 0 : 72)
                .padding(.top, 8)
                .padding(.bottom, 20)
            } // VStack
            .padding(.horizontal, 20)
            .sheet(isPresented: $isShowingSettingView) {
                SettingView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
            .sheet(isPresented: $isShowingCLMapView) {
                CLMapView(isShowingCLMapView: $isShowingCLMapView, savedLocation: $savedLocation) { locationName in
                    cLName = locationName
                    isShowingCLMapView = false // Dismiss sheet after saving
                }
                .presentationDetents([.large])
                .presentationCornerRadius(32)
            }
            .background(
                BackColorView(
                    isShowingResult: $isShowingResult,
                    selectedPicker: $selectedPicker
                )
            )
            .statusBarHidden()
            
            //Indexing Country Detail View
            if let expandedCountry = expandedCountry {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                NationDetailView(
                    countryName: $tappedCountry,
                    continent: $tappedContinent,
                    pickerFastOrSlow: $pickerFastOrSlow,
                    pickerHour: $pickerHour,
                    selectedPicker: $selectedPicker
                )
                .frame(maxWidth: .infinity)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .matchedGeometryEffect(id: expandedCountry.hashValue, in: animation)
                .padding(.top, 20)
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let yOffset = value.translation.height
                            if yOffset > 0 {
                                offset = yOffset
                            }
                        }
                        .onEnded { value in
                            if offset > threshold {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.1)) {
                                    self.expandedCountry = nil
                                    offset = .zero
                                    hiddenCountryIndices.remove(expandedCountry.hashValue)
                                }
                            } else {
                                withAnimation {
                                    offset = .zero
                                }
                            }
                        }
                )
                .zIndex(1)
                .edgesIgnoringSafeArea(.bottom)
            }
            
            if isLaunching {
                SplashView()
            }
        } //ZStack
        .onReceive(locationManager.$currentLocalName) { newLocation in
            self.currentLocalName = newLocation
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentTimeAString = cTimeA(tzOffset: calcCurrentLocalGMT())
                currentTimeHMMSSString = cTimeHMMSS(tzOffset: calcCurrentLocalGMT())
                currentDateStirng = cDate(tzOffset: calcCurrentLocalGMT())
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isLaunching = false
                }
            }
        }
    } //body
    
    func cTimeA(tzOffset: Int) -> String {
        let fmt = DateFormatter()
        let offsetInSeconds = tzOffset * 3600
        let targetTimeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        
        fmt.timeZone = targetTimeZone
        fmt.dateFormat = "a"
        fmt.locale = Locale(identifier: "en_US")
        
        return fmt.string(from: Date())
    }
    
    func cTimeHMMSS(tzOffset: Int) -> String {
        let fmt = DateFormatter()
        let offsetInSeconds = tzOffset * 3600
        let targetTimeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        
        fmt.timeZone = targetTimeZone
        fmt.dateFormat = "h:mm:ss"
        fmt.locale = Locale(identifier: "en_US")
        
        return fmt.string(from: Date())
    }
    
    func cDate(tzOffset: Int) -> String {
        let fmt = DateFormatter()
        let offsetInSeconds = tzOffset * 3600
        let targetTimeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        
        fmt.timeZone = targetTimeZone
        fmt.dateFormat = "E dd, MMM yyyy"
        fmt.locale = Locale(identifier: "en_US")
        
        return fmt.string(from: Date())
    }
} //struct
