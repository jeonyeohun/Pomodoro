//
//  DayViewController.swift
//  Pomodoro
//
//  Created by 김하람 on 2023/11/13.
//  Copyright © 2023 io.hgu. All rights reserved.
//

import SnapKit
import UIKit

final class DayViewController: DashboardBaseViewController {
    override var dateRange: Int {
        1
    }

    override func updateSelectedDateFormat() {
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let targetComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)

        if components.year == targetComponents.year,
           components.month == targetComponents.month,
           components.day == targetComponents.day {
            dateFormatter.dateFormat = "MM월 dd일, 오늘"
        } else {
            dateFormatter.dateFormat = "MM월 dd일"
        }
        dateLabel.text = dateFormatter.string(from: selectedDate)
    }
}
