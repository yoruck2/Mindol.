//
//  Font.swift
//  Mindol
//
//  Created by dopamint on 10/7/24.
//

import SwiftUI

extension Font {
    
    // Bold
//    static let pretendardBold24: Font = .custom("Pretendard-Bold", size: 24)
//    static let pretendardBold18: Font = .custom("Pretendard-Bold", size: 18)
//    static let pretendardBold14: Font = .custom("Pretendard-Bold", size: 14)
    static let badasseugiBold14: Font = .custom("HakgyoansimBadasseugiOTF-B", size: 14)
    static let badasseugiLight14: Font = .custom("HakgyoansimBadasseugiOTF-L", size: 14)
    
    static let iseoyun14: Font = .custom("LeeSeoyun", size: 14)
    static let gabiaGosran14: Font = .custom("Gabia-Gosran", size: 14)
    static let Geurimilgi14: Font = .custom("HakgyoansimGeurimilgiOTF-R", size: 14)
    static let nadeuriBold14: Font = .custom("HakgyoansimNadeuriOTF-B", size: 14)
    static let nadeuriLight14: Font = .custom("HakgyoansimNadeuriOTF-L", size: 14)
    static let saemaeul: Font = .custom("HSSaemaeul-Regular", size: 14)
    static let kyoboHandwriting14: Font = .custom("KyoboHandwriting2019", size: 14)
    static let ladywatermelon14: Font = .custom("ladywatermelon-Regular", size: 14)
}
enum CustomFontType {
    case badasseugiBold
    case badasseugiLight
    case iseoyun
    case gabiaGosran
    case Geurimilgi
    case nadeuriBold
    case nadeuriLight
    case saemaeul
    case kyoboHandwriting
    case ladywatermelon
    case dunggeunmisoBold
    case dunggeunmisoLight

    var name: String {
        switch self {
        case .badasseugiBold:
            "HakgyoansimBadasseugiOTF-B"
        case .badasseugiLight:
            "HakgyoansimBadasseugiOTF-L"
        case .iseoyun:
            "LeeSeoyun"
        case .gabiaGosran:
            "Gabia-Gosran"
        case .Geurimilgi:
            "HakgyoansimGeurimilgiOTF-R"
        case .nadeuriBold:
            "HakgyoansimNadeuriOTF-B"
        case .nadeuriLight:
            "HakgyoansimNadeuriOTF-L"
        case .saemaeul:
            "HSSaemaeul-Regular"
        case .kyoboHandwriting:
            "KyoboHandwriting2019"
        case .ladywatermelon:
            "ladywatermelon-Regular"
        case .dunggeunmisoBold:
            "HakgyoansimDunggeunmisoOTF-B"
        case .dunggeunmisoLight:
            "HakgyoansimDunggeunmisoOTF-L"
        }
    }
}


struct CustomFontViewModifier: ViewModifier {
    var fontType: CustomFontType
    var size: CGFloat
    func body (content: Content) -> some View {
        content
            .font(.custom(fontType.name, size: size))
    }
}

extension View {
    func customFont(type: CustomFontType, size: CGFloat = 17.0) -> some View {
        self.modifier(CustomFontViewModifier(fontType: type, size: size))
    }
}
