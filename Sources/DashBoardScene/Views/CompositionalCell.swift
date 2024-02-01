//
//  CompositionalCell.swift
//  Pomodoro
//
//  Created by 김하람 on 2023/11/13.
//  Copyright © 2023 io.hgu. All rights reserved.
//

import DGCharts
import SnapKit
import Then
import UIKit

final class FirstCell: UICollectionViewCell, DayViewControllerDelegate {
    
    let horizonDivider = UIView()
    let verticalDivider = UIView()
    let participateLabel = UILabel()
    let countLabel = UILabel()
    let achieveLabel = UILabel()
    let failLabel = UILabel()
    var getSelectedDate: Date = Date()
    
    func updateUI(for date: Date) {
        let filteredData = getPomodoroData(forDate: date)
        let totalParticipate = getTotalParticipateDate(forDate: date)
        let participateCount = totalParticipate.count
        let totalSuccessCount = filteredData.filter { $0.success }.count
        let totalFailureCount = filteredData.filter { !$0.success }.count
        participateLabel.text = "참여일  \(participateCount)"
        countLabel.text = "횟수 \(filteredData.count)"
        achieveLabel.text = "달성 \(totalSuccessCount)"
        failLabel.text = "실패 \(totalFailureCount)"
    }
    
    private func setupLabel(_ label: UILabel, text: String, topOffset: CGFloat, centerXOffset: CGFloat) {
        label.textColor = .white
        label.text = text
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.centerX.equalToSuperview().offset(centerXOffset)
        }
    }
    
    private func setupDivider(_ divider: UIView, isHorizontal: Bool, length: CGFloat, offset: CGFloat) {
        divider.backgroundColor = .white
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            if isHorizontal {
                make.width.equalTo(length)
                make.height.equalTo(1)
            } else {
                make.width.equalTo(1)
                make.height.equalTo(length)
            }
            make.top.equalToSuperview().offset(offset)
            make.centerX.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("이 생성자를 사용하려면 스토리보드를 구현해주세요.")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        let filteredData = getPomodoroData(forDate: getSelectedDate)
        let totalParticipate = getTotalParticipateDate(forDate: getSelectedDate)
        let participateCount = totalParticipate.count
        let totalSuccessCount = filteredData.filter { $0.success }.count
        let totalFailureCount = filteredData.filter { !$0.success }.count
        
        setupLabel(participateLabel, text: "참여일 \(participateCount)", topOffset: 70, centerXOffset: -100)
        setupLabel(countLabel, text: "횟수 \(filteredData.count)번", topOffset: 70, centerXOffset: 50)
        setupLabel(achieveLabel, text: "달성 \(totalSuccessCount)번", topOffset: 160, centerXOffset: -100)
        setupLabel(failLabel, text: "실패 \(totalFailureCount)번", topOffset: 160, centerXOffset: 50)
        setupDivider(horizonDivider, isHorizontal: true, length: 325, offset: 130)
        setupDivider(verticalDivider, isHorizontal: false, length: 155, offset: 50)
        
        layer.cornerRadius = 20
        backgroundColor = .black
    }
    
    func sendSelectedDate(data: Date) {
        getSelectedDate = data
    }
    
    private func getTotalParticipateDate(forDate date: Date) -> [PomodoroData] {
        PomodoroData.dummyData.filter { $0.participateDate <= date }
    }
    private func getPomodoroData(forDate date: Date) -> [PomodoroData] {
        let calendar = Calendar.current
        return PomodoroData.dummyData.filter {
            calendar.isDate($0.participateDate, inSameDayAs: date)
        }
    }
}

final class SecondCell: UICollectionViewCell, DayViewControllerDelegate {
    private var getSelectedDate: Date = Date()
    
    func sendSelectedDate(data: Date) {
        getSelectedDate = data
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
    
    private func setPieChartData(pieChartView: PieChartView) {
        var totalSum = 0.0
        let sessionsPerTag = calculateFocusTimePerTag(for: Date())
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
        pieChartView.data = pieChartData
        pieChartView.centerText = "합계\n\(totalSum)"
    }
    
    func updatePieChartData(for date: Date) {
        var totalSum = 0.0
        let sessionsPerTag = calculateFocusTimePerTag(for: date)
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
    
    private var dayData: [String] = [""]
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
        setPieChartData(pieChartView: donutPieChartView)
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
}