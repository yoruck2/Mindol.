//
//  SettingsView.swift
//  Mindol
//
//  Created by dopamint on 10/4/24.
//

import SwiftUI

// 설정 항목의 타입을 정의하는 열거형
enum SettingType {
    case navigation
    case toggle
    case info
}

// 설정 항목을 나타내는 구조체
struct SettingItem: Identifiable {
    let id = UUID()
    let name: String
    let type: SettingType
    var isOn: Bool = false
    var destination: AnyView? = nil
}

// 설정 화면을 구성하는 뷰
struct SettingsView: View {
    @State private var settings: [SettingItem] = [
        SettingItem(name: "앱 버전", type: .info)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach($settings) { $setting in
                    settingRow(for: $setting)
                }
            }
            .navigationTitle("설정")
        }
    }
    
    @ViewBuilder
    func settingRow(for setting: Binding<SettingItem>) -> some View {
        switch setting.wrappedValue.type {
        case .navigation:
            if let destination = setting.wrappedValue.destination {
                NavigationLink(destination: destination) {
                    Text(setting.wrappedValue.name)
                }
            }
        case .toggle:
            HStack {
                Text(setting.wrappedValue.name)
                Spacer()
                Toggle("", isOn: setting.isOn)
            }
        case .info:
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            HStack {
                Text(setting.wrappedValue.name)
                Spacer()
                Text(version)
            }
        }
    }
}

