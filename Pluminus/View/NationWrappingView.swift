//
//  NationView.swift
//  Pluminus
//
//  Created by kimsangwoo on 2023/08/17.
//

import SwiftUI
import WrappingHStack

struct NationWrappingView: View {
    @State private var isShowingModal: Bool = false
    @State private var isShowingMap: Bool = false
    @State private var tappedCountry: String = ""
    @State private var tappedContinent: String = ""
    @State private var tappedLocality: String = ""
    
    @Binding var pickerHour: Int
    @Binding var pickerFastOrSlow: [String]
    @Binding var selectedPicker: [Int]
    
    var body: some View {
        VStack(alignment: .leading) {
            if CountryList.list.GMT[calcTargetLocalGMT(selectedPicker: selectedPicker)] != nil {
                WrappingHStack(CountryList.list.GMT[calcTargetLocalGMT(selectedPicker: selectedPicker)]!, id: \.self) { tag in
                    Button {
                        HapticManager.instance.impact(style: .rigid)
                        if tag.isHaveLocality {
                            showLocality(isShowingModal: tag.isHaveLocality, countryName: tag.countryName, continent: tag.continent)
                        } else {
                            showLocality(isShowingModal: tag.isHaveLocality, countryName: tag.countryName, continent: tag.continent)
                            self.isShowingMap = true
                        }
                    } label: {
                        HStack {
                            Text(tag.countryName)
                                .font(.system(size: 17, weight: .bold))
                                .padding(.horizontal, 6)
                                .frame(height: 24)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.black)
                            if tag.isHaveLocality {
                                Image(systemName: "ellipsis.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.orange)
                            }
                        } // HStack
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.white)
                        .cornerRadius(32)
                    } // Button
                    .padding(.bottom, 16)
                } // WrappingHStack
            } else {
                Text("다시 시도해주세요.")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
            }
        } // VStack
        .sheet(isPresented: $isShowingModal) {
            NationDetailView(
                countryName: $tappedCountry,
                continent: $tappedContinent,
                pickerFastOrSlow: $pickerFastOrSlow,
                pickerHour: $pickerHour,
                selectedPicker: $selectedPicker
            )
            .presentationDetents([.large])
            .presentationCornerRadius(32)
        }
        .sheet(isPresented: $isShowingMap) {
            NationInfoMapView(
                countryName: $tappedCountry,
                continent: $tappedContinent,
                locality: $tappedLocality
            )
            .presentationDetents([.large])
            .presentationCornerRadius(32)
        } //sheet
    } // body
    
    private func showLocality(isShowingModal: Bool, countryName: String, continent: String) {
        if isShowingModal {
            self.isShowingModal = true
            self.tappedCountry = countryName
            self.tappedContinent = continent
        } else {
            self.tappedCountry = countryName
            self.tappedContinent = continent
        }
    }
} // struct
