//
//  DashBoardViewController.swift
//  Pomodoro
//
//  Created by 진세진 on 2023/11/06.
//  Copyright © 2023 io.hgu. All rights reserved.
//

import SnapKit
import UIKit

final class DashBoardViewController: UIViewController {
    private enum SegmentItem: Int {
        case day
        case week
        case month
        case year
    }

    private let containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSegmentedControl()
        setupContainerView()
        segmentChanged()
    }

    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(tabBarControl.snp.bottom).offset(30)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private let tabBarControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["일", "주", "월", "년"])
        segmentedControl.backgroundColor = .white
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private func setupSegmentedControl() {
        view.addSubview(tabBarControl)
        tabBarControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(300)
        }
        tabBarControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func displayViewController(_ currentViewType: DashboardContentViewController.DashboardDateType) {
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }

        let viewController = DashboardContentViewController()
        viewController.dashboardDateType = currentViewType
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.didMove(toParent: self)
    }

    @objc private func segmentChanged() {
        if let viewController = DashboardContentViewController.DashboardDateType(rawValue: tabBarControl.selectedSegmentIndex) {
            displayViewController(viewController)
        }
    }
}
