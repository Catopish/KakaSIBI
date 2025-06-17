//
//  Extensions.swift
//  MachineLearningChallenge
//
//  Created by Brayen Fredgin Cahyadi on 17/06/25.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx * dx + dy * dy)
    }
}

