//
//  WrappedIndexingCountryComponent.swift
//  Pluminus
//
//  Created by kimsangwoo on 7/7/24.
//

import SwiftUI
import WrappingHStack

struct WrappedIndexingCountryComponent: View {
    var animation: Namespace.ID
    
    @Binding var expandedCountry: Country?
    @Binding var hiddenCountryIndices: Set<Int>
    @Binding var tappedCountry: String
    @Binding var tappedContinent: String
    
    @Binding var selectedPicker: [Int]
    
    var body: some View {
        ScrollView {
            let countries = CountryList.list.GMT[calcTargetLocalGMT(selectedPicker: selectedPicker)]
            
            if countries != nil {
                WrappingHStack(countries!, id: \.self) { country in
                    Button {
                        HapticManager.instance.impact(style: .rigid)
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.95, blendDuration: 0.9)) {
                            if expandedCountry?.countryName == country.countryName {
                                expandedCountry = nil
                            } else {
                                expandedCountry = country
                                tappedCountry = country.countryName
                                tappedContinent = country.continent
                            }
                        }
                    } label: {
                        HStack {
                            Text(country.countryName)
                                .font(.system(size: 17, weight: .bold))
                                .padding(.horizontal, 6)
                                .frame(height: 24)
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.black)
                            if country.isHaveLocality {
                                Image(systemName: "ellipsis.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.orange)
                            }
                        } // HStack
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 32)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 32)
                                .strokeBorder(lineWidth: 1)
                                .foregroundStyle(Color.secondary.opacity(0.1))
                        }
                        .opacity(hiddenCountryIndices.contains(country.hashValue) ? 0 : 1)
                        .matchedGeometryEffect(id: country.hashValue, in: animation)
                    } // Button
                    .padding(.vertical, 6)
                } // WrappingHStack
                .padding(.vertical, 12)
            } else {
                Text("Indexing Error!")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .scrollIndicators(.hidden)
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .black, location: 0.05),
                    .init(color: .black, location: 0.95),
                    .init(color: .clear, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    } //body
} //struct
