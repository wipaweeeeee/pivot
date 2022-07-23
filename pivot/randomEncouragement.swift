//
//  randomEncouragement.swift
//  pivot
//
//  Created by Wipawe Sirikolkarn on 7/22/22.
//

import SwiftUI

struct randomEncouragement: View {
    
    var count: Int
    var options: Array<String> = [
        "Tap anywhere to play",
        "Juicy adventures await this way",
        "Breathe...then go!",
        "Go, and don't look back",
        "Live a little",
        "This is gonna be great",
        "Find somewhere to sit",
        "Take a photo of the first thing you see here",
        "Say hi to that person",
        "I smell a gelato that way",
        "Take it slow",
        "Go at your own pace",
        "This should be fun"
    ]
    
    var body: some View {
        VStack {
            Spacer().frame(height: 300)
            if (count > -1) {
                Text(options[count])
            }
        }
    }
}

