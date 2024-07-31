//
//  LoyaltyViewController.swift
//  _LocalDebugOptions
//
//  Created by Oleksii Zabrodin on 11.01.2024.
//

import UIKit
import ELBase
import ElloAppApi
import SwiftSignalKit
import ElloAppApi
import ElloAppCore
import UndoUI
import ElloAppCallsUI
import Display
import AccountContext
import AnimationUI

class LoyaltyViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet var navigation: UINavigationItem!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var myProgressButton: UIButton!
    @IBOutlet var myReferalsButton: UIButton!
    @IBOutlet var tabsView: UIView!
    @IBOutlet var myProgressView: UIView!
    @IBOutlet var myReferalsView: UIView!
    
    @IBOutlet var progressValueLable: UILabel!
    @IBOutlet var progressUpConstraint: NSLayoutConstraint!
    @IBOutlet var progressDownConstraint: NSLayoutConstraint!
    @IBOutlet var progressShieldView: UIView!
    @IBOutlet var progressUnderlineView: UIView!
    
    @IBOutlet var referalsValueLable: UILabel!
    @IBOutlet var referalsTableView: UITableView!
    @IBOutlet var referalsUpConstraint: NSLayoutConstraint!
    @IBOutlet var rerferalsDownConstraint: NSLayoutConstraint!
    @IBOutlet var referralsLabel: UILabel!
    @IBOutlet var referalCodeLinkLabel: UILabel!
    @IBOutlet var referalCodeLabel: UILabel!
    @IBOutlet var referalShieldView: UIView!
    @IBOutlet var referalsUnderlineView: UIView!
    @IBOutlet var spiner: UIActivityIndicatorView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var imageEmptyView: UIView!

    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var referralNameLabel: UILabel!
    @IBOutlet var referralDiscriptionLabel: UILabel!
    
    // MARK: - Properties
    public var requestService: RequestService?
    public var accountContext: AccountContext?
    
    private let emptyResultsAnimationNode = AnimationNode()
    private var referalCodeLink: String?
    private var users:[Api.loyalty.LoyaltyUser]? {didSet{
        self.referalsTableView?.reloadData()
        emptyView?.isHidden = !(users?.isEmpty ?? true)
    }}
    
    @IBAction func onBackTap(_ sender: Any) {
        onTapBack?()
    }
    
    private var progressShieldOffset:CGPoint = CGPointZero
    @IBAction func onProgressUpGesture(_ sender: Any) {
        progressShieldOffset = self.progressShieldView.frame.origin
        let frame = CGRect(origin: CGPointZero, size: progressShieldView.frame.size)
        
        UIView.animate(withDuration: 0.3) {
            self.progressShieldView.layer.frame = frame
        } completion: { _ in
            self.progressDownConstraint.isActive = false
            self.progressUpConstraint.isActive = true
            self.tabsView.isHidden = true
        }
    }
    
    @IBAction func onProgressDownGesture(_ sender: Any) {
        let frame = CGRect(origin: progressShieldOffset, size: progressShieldView.frame.size)

        UIView.animate(withDuration: 0.3) {
            self.progressShieldView.layer.frame = frame
        } completion: { _ in
            self.progressDownConstraint.isActive = true
            self.progressUpConstraint.isActive = false
            self.tabsView.isHidden = !self.isBusiness
        }
    }
    
    private var referalShieldOffset:CGPoint = CGPointZero
    @IBAction func onReferalsUpGesture(_ sender: Any) {
        self.referalShieldOffset = self.referalShieldView.frame.origin
        let frame = CGRect(origin: CGPointZero, size: referalShieldView.frame.size)

        UIView.animate(withDuration: 0.3) {
            self.referalShieldView.layer.frame = frame
        } completion: { _ in
            self.rerferalsDownConstraint.isActive = false
            self.referalsUpConstraint.isActive = true
            self.tabsView.isHidden = true
        }
    }
    
    @IBAction func onReferalsDownGesture(_ sender: Any) {
        let frame = CGRect(origin: referalShieldOffset, size: referalShieldView.frame.size)
        
        UIView.animate(withDuration: 0.3) {
            self.referalShieldView.layer.frame = frame
        } completion: { _ in
            self.rerferalsDownConstraint.isActive = true
            self.referalsUpConstraint.isActive = false
            self.tabsView.isHidden = false
        }
    }
    
    @IBAction func onMyProgressButton(_ sender: Any) {
        myProgressButton.isSelected = true
        myReferalsButton.isSelected = false
        progressUnderlineView.isHidden = false
        referalsUnderlineView.isHidden = true
        scrollView.contentOffset = CGPointZero
    }
    
    @IBAction func onMyReferalsButton(_ sender: Any) {
        myProgressButton.isSelected = false
        myReferalsButton.isSelected = true
        progressUnderlineView.isHidden = true
        referalsUnderlineView.isHidden = false
        scrollView.contentOffset = CGPoint(x:myReferalsView.frame.origin.x, y:0)
    }
    
    @IBAction func onReferalCodeLinkTap(_ sender: Any) {
        UIPasteboard.general.string = self.referalCodeLink
        present(ToastViewController.controller!, animated: true)
    }
    
    @IBAction func onReferralCodeTap(_ sender: Any) {
        UIPasteboard.general.string = self.referalCodeLabel.text
        let toast = ToastViewController.controller!
        toast.type = .copied
        present(toast, animated: true)
    }
    
    @IBAction func onShareWithFriendsTap(_ sender: Any) {
        guard let referalCodeLink else { return }
        let activityController = UIActivityViewController(activityItems: [referalCodeLink], applicationActivities: nil)
        if let window = self.view.window {
            activityController.popoverPresentationController?.sourceView = window
            activityController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: window.bounds.width / 2.0, y: window.bounds.size.height - 1.0), size: CGSize(width: 1.0, height: 1.0))
        }
        self.present(activityController, animated: true)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let animationView = self.emptyResultsAnimationNode.animationView() {
            animationView.frame = imageEmptyView.bounds
            animationView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            self.imageEmptyView.addSubview(animationView)
            self.emptyResultsAnimationNode.setAnimation(name: "TransactionHistoryNoResults")
            emptyResultsAnimationNode.loop()
        }
        
        guard let userID = accountContext?.account.peerId.id._internalGetInt64Value() else { return }
        
        isBusiness = false
        requestService!.makeGenBonusCode(user:Api.loyalty.User(id: Int(userID))){[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let code):
                print(code)
                self.referalCodeLabel.text = code.code
                self.referalCodeLink = "https://ello.team/invite_referral?code=" + code.code

            case .failure(let error):
                print(error)
            }
        }

        spiner.isHidden = false
        requestService!.makeGetLoyaltyBonusDataWithSum(with: Api.loyalty.User(id: Int(userID))) {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let code):
                print(code)
                self.referalsValueLable.text = (code.sum ?? 0).stringFinanceFormat
                self.progressValueLable.text = (code.sum ?? 0).stringFinanceFormat
                self.referralsLabel.text = String(code.count_users ?? 0) + " " + "Referrals".localized
                
                requestService!.makeGetRefUsers(userWithPagination: Api.loyalty.UserWithPagination(id: Int(userID),
                                                                                                   pagination: Api.loyalty.Pagination(page: 0, per_page: 100))) {[weak self] result in
                    guard let self else { return }
                    switch result {
                        case .success(let users):
                            self.users = users.users
                            self.isBusiness = code.loyalty_data.is_business ?? false
                            self.referralNameLabel.isHidden = false
                            self.referralNameLabel.text = code.loyalty_data.name
                            self.referralDiscriptionLabel.isHidden = false
                            self.referralDiscriptionLabel.text = code.loyalty_data.desc
                            self.spiner.isHidden = true

                        case .failure(let error):
                            print(error)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Loyalty"
    }
    
    private var isBusiness:Bool = false { didSet{
        tabsView.isHidden = !isBusiness
        scrollView.isScrollEnabled = isBusiness
    }}
}

extension LoyaltyViewController:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset == .zero {
            myProgressButton.isSelected = true
            myReferalsButton.isSelected = false
            progressUnderlineView.isHidden = false
            referalsUnderlineView.isHidden = true

        }
        else {
            myProgressButton.isSelected = false
            myReferalsButton.isSelected = true
            progressUnderlineView.isHidden = true
            referalsUnderlineView.isHidden = false
        }
    }
}
                                    
extension LoyaltyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoyaltyUserTableViewCell.reuseIdentifier, for: indexPath) as! LoyaltyUserTableViewCell
        let user = users![indexPath.row]
        cell.nameLabel.text = user.user.username
        cell.totalValueLabel.text = (user.sum)?.stringFinanceFormat ?? 0.stringFinanceFormat
        cell.yourValueLabel.text = (user.commission ?? 0.0).stringFinanceFormat
        return cell
    }
}

extension LoyaltyViewController {
    private func showAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let image = UIImage(named: "myImage")
        let alertController = AlertViewController.createAlertControllerWithImage(
            title: "Error: Something went wrong.",
            message: "Please try again.",
            preferredStyle: .alert,
            actions: [okAction],
            image: image
        )
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
