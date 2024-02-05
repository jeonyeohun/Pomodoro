//
//  DashboardBaseViewController.swift
//  Pomodoro
//
//  Created by USER on 2024/02/05.
//

import SnapKit
import UIKit

protocol DashboardTabDelegate: AnyObject {
    func dateArrowButtonDidTap(data: Date)
}

class DashboardBaseViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case status
        case chart
    }

    weak var delegate: DashboardTabDelegate?
    let dashboardStatusCell = DashboardStatusCell()
    let dashboardPieChartCell = DashboardPieChartCell()
    var selectedDate = Date()
    let calendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDateLabel()
        setupArrowButtons()
        setupCollectionView()
    }

    let dateFormatter = DateFormatter().then {
        $0.dateStyle = .long
    }

    var dateRange: Int {
        0
    }

    lazy var dateLabel = UILabel().then {
        $0.text = dateFormatter.string(from: selectedDate)
        $0.textAlignment = .center
        $0.textColor = .black
    }

    private lazy var previousButton = UIButton().then {
        $0.setImage(
            UIImage(
                systemName: "arrowtriangle.backward"
            )?.withTintColor(.black, renderingMode: .alwaysOriginal),
            for: .normal
        )
        $0.addTarget(self, action: #selector(goToPreviousDate), for: .touchUpInside)
    }

    private lazy var nextButton = UIButton().then {
        $0.setImage(
            UIImage(
                systemName: "arrowtriangle.right"
            )?.withTintColor(.black, renderingMode: .alwaysOriginal),
            for: .normal
        )

        $0.addTarget(self, action: #selector(goToNextDate), for: .touchUpInside)
    }

    @objc func goToNextDate() {
        guard let nextDate = calendar.date(byAdding: .day, value: dateRange, to: selectedDate),
              nextDate <= .now
        else {
            return
        }

        selectedDate = nextDate
        updateSelectedDateFormat()
        delegate?.dateArrowButtonDidTap(data: selectedDate)
        dashboardStatusCell.dateArrowButtonDidTap(data: selectedDate)
        dashboardPieChartCell.dateArrowButtonDidTap(data: selectedDate)
        collectionView.reloadData()
    }

    @objc func goToPreviousDate() {
        guard let previousDate = calendar.date(byAdding: .day, value: -dateRange, to: selectedDate) else {
            return
        }
        selectedDate = previousDate

        updateSelectedDateFormat()
        delegate?.dateArrowButtonDidTap(data: selectedDate)
        dashboardStatusCell.dateArrowButtonDidTap(data: selectedDate)
        dashboardPieChartCell.dateArrowButtonDidTap(data: selectedDate)
        collectionView.reloadData()
    }

    func updateSelectedDateFormat() {}

    lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: self.getLayout()
    ).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.clipsToBounds = true
        $0.register(DashboardStatusCell.self, forCellWithReuseIdentifier: "DashboardStatusCell")
        $0.register(DashboardPieChartCell.self, forCellWithReuseIdentifier: "DashboardPieChartCell")
    }

    private func setupDateLabel() {
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    private func setupArrowButtons() {
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        previousButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(dateLabel.snp.trailing).offset(10)
        }
    }

    private func getLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in

            func makeItem() -> NSCollectionLayoutItem {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let itemInset: CGFloat = 3.0
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: itemInset,
                    leading: itemInset,
                    bottom: itemInset,
                    trailing: itemInset
                )
                item.contentInsets.leading = 15
                item.contentInsets.trailing = 15
                item.contentInsets.top = 15

                return item
            }

            func makeGroup(heightFraction: CGFloat) -> NSCollectionLayoutGroup {
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(heightFraction)
                )
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [makeItem()])
            }

            switch section {
            case 0:
                return NSCollectionLayoutSection(group: makeGroup(heightFraction: 1.0 / 3.0))
            default:
                return NSCollectionLayoutSection(group: makeGroup(heightFraction: 1.0 / 2.0))
            }
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom)
        }
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDataSource

extension DashboardBaseViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .status:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DashboardStatusCell",
                for: indexPath
            ) as? DashboardStatusCell else {
                return UICollectionViewCell()
            }
            cell.updateUI(for: selectedDate, isWeek: false)
            return cell

        case .chart:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DashboardPieChartCell",
                for: indexPath
            ) as? DashboardPieChartCell else {
                return UICollectionViewCell()
            }
            cell.setPieChartData(for: selectedDate, isWeek: false)
            return cell
        case .none:
            return UICollectionViewCell()
        }
    }
}
