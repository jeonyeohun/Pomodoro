//
//  WeekViewController.swift
//  Pomodoro
//
//  Created by 김하람 on 2023/11/13.
//  Copyright © 2023 io.hgu. All rights reserved.
//

import SnapKit
import UIKit

final class WeekViewController: DashboardBaseViewController {
    override var dateRange: Int {
        7
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedDateFormat()
    }

    override func updateSelectedDateFormat() {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"

        if let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) {
            let startDate = weekInterval.start
            let endDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)

            dateLabel.text = "\(startDateString) - \(endDateString)"
        }
    }
}
