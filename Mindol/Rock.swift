

//
//  RockStackScene.swift
//  Mindol
//
//  Created by dopamint on 9/22/24.
//

import SwiftUI

enum Rock: String, CaseIterable, Identifiable {
    case anger, flutter, sad, calm, joy, rock, example
    
    var id: String { self.rawValue }
    var image: Image {
        Image(self.rawValue)
    }
}

