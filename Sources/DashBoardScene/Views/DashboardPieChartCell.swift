//
//  DashboardPieChartCell.swift
//  Pomodoro
//
//  Created by 김하람 on 1/30/24.
//  Copyright © 2024 io.hgu. All rights reserved.
//

import UIKit
import DGCharts

final class DashboardPieChartCell: UICollectionViewCell {
    private var selectedDate: Date = Date()
    private var dayData: [String] = []
    private var priceData: [Double] = [10]
    
    private let pieBackgroundView = UIView().then { view in
        view.layer.cornerRadius = 20
        view.backgroundColor = .systemGray3
    }
    
    private let donutPieChartView = PieChartView().then { chart in
        chart.noDataText = "출력 데이터가 없습니다."
        chart.noDataFont = .systemFont(ofSize: 20)
        chart.noDataTextColor = .black
        chart.holeColor = .systemGray3
        chart.backgroundColor = .systemGray3
        chart.legend.font = .systemFont(ofSize: 15)
        chart.drawSlicesUnderHoleEnabled = false
        chart.holeRadiusPercent = 0.55
        chart.drawEntryLabelsEnabled = false
        chart.legend.enabled = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(pieBackgroundView)
        pieBackgroundView.addSubview(donutPieChartView)
        self.backgroundColor = .systemGray3
        layer.cornerRadius = 20
        setupPieChart()
        setPieChartData(for: Date())
    }
    
    private func calculateFocusTimePerTag(for selectedDate: Date) -> [String: Int] {
        let calendar = Calendar.current
        var focusTimePerTag = [String: Int]()
        
        let filteredSessions = PomodoroData.dummyData.filter { session in
            return calendar.isDate(session.participateDate, inSameDayAs: selectedDate)
        }
        for session in filteredSessions {
            focusTimePerTag[session.tagId, default: 0] += session.focusTime
        }
        return focusTimePerTag
    }
    
    private func setupPieChart() {
        pieBackgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.8)
        }
        donutPieChartView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(1.1)
        }
    }
    
    private func entryData(values: [Double]) -> [ChartDataEntry] {
        var pieDataEntries: [ChartDataEntry] = []
        for i in 0 ..< values.count {
            let pieDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            pieDataEntries.append(pieDataEntry)
        }
        return pieDataEntries
    }
    
    private func calculateFocusTimePerTag(from startDate: Date, to endDate: Date) -> [String: Int] {
        let calendar = Calendar.current
        var focusTimePerTag = [String: Int]()
        
        let filteredSessions = PomodoroData.dummyData.filter { session in
            return session.participateDate >= startDate && session.participateDate < endDate
        }
        for session in filteredSessions {
            focusTimePerTag[session.tagId, default: 0] += session.focusTime
        }
        return focusTimePerTag
    }
    
    func setPieChartData(for date: Date, isWeek: Bool = false) {
        var totalSum = 0.0
        var sessionsPerTag: [String: Int] = [:]
        
        let calendar = Calendar.current
        
        if isWeek {
            if let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)),
               let weekEndDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate) {
                sessionsPerTag = calculateFocusTimePerTag(from: weekStartDate, to: weekEndDate)
            }
        } else {
            let startOfDay = calendar.startOfDay(for: date)
            if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) {
                sessionsPerTag = calculateFocusTimePerTag(from: startOfDay, to: endOfDay)
            }
        }
        
        var pieDataEntries: [PieChartDataEntry] = []
        let colors: [UIColor] = [.systemTeal, .systemPink, .systemIndigo]
        
        for (tag, count) in sessionsPerTag {
            let entry = PieChartDataEntry(value: Double(count), label: tag)
            pieDataEntries.append(entry)
            totalSum += Double(count)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: pieDataEntries, label: "")
        pieChartDataSet.colors = colors
        pieChartDataSet.drawValuesEnabled = true
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        donutPieChartView.data = pieChartData
        donutPieChartView.centerText = "합계\n\(totalSum)"
    }
}

extension DashboardPieChartCell: DashboardTabDelegate {
    func dateArrowButtonDidTap(data date: Date) {
        selectedDate = date
    }
}
