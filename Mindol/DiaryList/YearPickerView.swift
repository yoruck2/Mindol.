//
//  YearPickerView.swift
//  Mindol
//
//  Created by dopamint on 10/5/24.
//

import SwiftUI

struct YearPickerView: View {
    @Binding var selectedYear: Int
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0
    @State private var tempSelectedYear: Int
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let yearRange: [Int]
    
    init(selectedYear: Binding<Int>, isPresented: Binding<Bool>) {
        self._selectedYear = selectedYear
        self._isPresented = isPresented
        let currentYear = Calendar.current.component(.year, from: Date())
        self.yearRange = Array((currentYear - 100)...currentYear).reversed()
        self._tempSelectedYear = State(initialValue: selectedYear.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissView()
                }
            
            VStack {
                Text("년도 선택")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    LazyVStack {
                        ForEach(yearRange, id: \.self) { year in
                            Button(action: {
                                tempSelectedYear = year
                            }) {
                                Text(String(year))
                                    .foregroundColor(tempSelectedYear == year ? .blue : .primary)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .frame(height: 200)
                
                Button("선택") {
                    selectedYear = tempSelectedYear
                    dismissView()
                }
                .padding()
            }
            .frame(width: 250, height: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.easeOut(duration: 0.2)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
