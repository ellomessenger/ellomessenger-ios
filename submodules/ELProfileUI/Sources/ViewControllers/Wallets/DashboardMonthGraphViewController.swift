//
//  DashboardMonthGraphViewController.swift
//  _idx_ELProfileUI_F5FB5BFD_ios_min14.0
//
//

import UIKit
import ElloAppApi
import ELBase

enum GraphColors {
    enum Green {
        static let first = UIColor(hex: 0x44BE2E)
        static let second = UIColor(hex: 0x27AE60)
    }
    
    enum Red {
        static let first = UIColor(hex: 0xFF758F)
        static let second = UIColor(hex: 0xEF4061)
    }
}

class DashboardMonthGraphViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var stackView: UIStackView!
    
    // MARK: - Properties
    var requestService: RequestService?
    var wallet: Api.wallet.WalletItem?
    var commonAmountHandler: EventClosure<Double>?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGraph()
        requestLastMonthActivityGraphic()
    }
    
    // MARK: - Set up
    private func configure(progressView: UIProgressView, with activityItem: MonthActivityItem, commonAmount: Double) {
        if activityItem.type == .deposit {
            progressView.progressImage = UIImage(
                bounds: .init(origin: .zero, size: .init(width: 57, height: 6)),
                colors: [GraphColors.Green.first, GraphColors.Green.second]
            )
        } else {
            progressView.progressImage = UIImage(
                bounds: progressView.bounds,
                colors: [GraphColors.Red.first, GraphColors.Red.second]
            )
        }
        
        progressView.setProgress(Float(activityItem.amount / max(1, commonAmount)), animated: false)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            progressView.layoutIfNeeded()
        }
    }
    
    // MARK: - IBActions
    
    // MARK: - Actions
    private func createGraph() {
        let calendar = Calendar.current
        let date = Date()
        
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            return
        }
        guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else {
            return
        }
        
        for _ in 0..<days {
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.trackTintColor = UIColor(hex: 0x070708, alpha: 0.05)
            progressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
            progressView.layer.sublayers?[safe: 1]?.cornerRadius = 3
            progressView.subviews[safe: 1]?.clipsToBounds = true
            
            let progressContainerView = UIView()
            progressContainerView.translatesAutoresizingMaskIntoConstraints = false
            progressContainerView.addSubview(progressView)
            NSLayoutConstraint.activate([
                progressView.heightAnchor.constraint(equalToConstant: 6),
                progressView.widthAnchor.constraint(equalToConstant: 57),
                progressView.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
                progressView.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor)
            ])
            
            stackView.addArrangedSubview(progressContainerView)
            NSLayoutConstraint.activate([
                progressContainerView.heightAnchor.constraint(equalToConstant: 57),
            ])
        }
    }
    
    private func fillGraph(activity: MonthActivityItems) {
        guard !activity.data.isEmpty else {
            stackView.arrangedSubviews.forEach {
                ($0.subviews.first as? UIProgressView)?.setProgress(0, animated: true)
            }
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        activity.data.forEach { activityItem in
            guard let date = formatter.date(from: activityItem.date) else {
                return
            }
            guard let day = calendar.dateComponents([.day], from: date).day else {
                return
            }
            // day - 1 - becouse days starts from 1
            guard let progressView = stackView.arrangedSubviews[safe: day - 1]?.subviews.first as? UIProgressView else {
                return
            }
            
            configure(progressView: progressView, with: activityItem, commonAmount: activity.amount)
        }
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    func requestLastMonthActivityGraphic(page: Int = 0) {
        guard let wallet else { return }
        
        requestService?.lastMonthActivityGraphic(walletId: wallet.id, limit: 100, page: page) { [weak self] result in
            switch result {
            case .success(let lastMonthActivity):
                self?.commonAmountHandler?(lastMonthActivity.amount)
                self?.fillGraph(activity: lastMonthActivity)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
