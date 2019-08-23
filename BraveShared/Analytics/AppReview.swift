// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import StoreKit

public class AppReview {
    
    public static let MINIMUM_DAYS_BETWEEN_REVIEWS = 60
    
    public enum ReviewThreshold: Int, Codable, UserDefaultsEncodable {
        case first = 14
        case second = 41
        case third = 121
    }
    
    @discardableResult
    public static func requestReviewIfNecessary(date: Date = Date()) -> Bool {
        let launchCount = Preferences.Review.launchCount.value
        let threshold = Preferences.Review.threshold.value
        
        var daysSinceLastRequest = 0
        if let previousRequest = Preferences.Review.lastReviewDate.value {
            daysSinceLastRequest = Calendar.current.dateComponents([.day], from: previousRequest, to: date).day ?? 0
        } else {
            daysSinceLastRequest = MINIMUM_DAYS_BETWEEN_REVIEWS
        }
        
        if launchCount < threshold.rawValue || daysSinceLastRequest <= MINIMUM_DAYS_BETWEEN_REVIEWS {
            return false
        }
        
        Preferences.Review.lastReviewDate.value = date
        
        switch threshold {
        case .first:
            Preferences.Review.threshold.value = .second
        case .second:
            Preferences.Review.threshold.value = .third
        default:
            break
        }
        
        SKStoreReviewController.requestReview()
        return true
    }
}
