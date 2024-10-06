//
//  DatePickerView.swift
//  Mindol
//
//  Created by dopamint on 10/5/24.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int?
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0
    @State private var tempSelectedYear: Int
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let yearRange: [Int]
    private let months = [nil] + Array(1...12)
    
    init(selectedYear: Binding<Int>, selectedMonth: Binding<Int?>, isPresented: Binding<Bool>) {
        self._selectedYear = selectedYear
        self._selectedMonth = selectedMonth
        self._isPresented = isPresented
        let currentYear = Calendar.current.component(.year, from: Date())
        self.yearRange = Array(1900...currentYear).reversed()
        self._tempSelectedYear = State(initialValue: selectedYear.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissView()
                }
            
            VStack(spacing: 20) {
                
                
                HStack {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(yearRange, id: \.self) { year in
                            Text("\(year.description)년").tag(year)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 95)
                    .clipped()
                    
                    Picker("Month", selection: $selectedMonth) {
                        Text("전체").tag(nil as Int?)
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)월").tag(month as Int?)
                        }
                    }
                    .pickerStyle(.inline)
                    .frame(width: 60)
                    .clipped()
                    Text("의 기억을 볼래요")
                        .font(.headline)
                }
                
                Button("선택") {
                    dismissView()
                }
                .padding()
            }
            .frame(width: 300, height: 250)
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
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
//        }
    }
}
