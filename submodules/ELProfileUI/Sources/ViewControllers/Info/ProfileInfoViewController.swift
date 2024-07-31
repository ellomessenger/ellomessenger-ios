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

public class ProfileInfoViewController: BaseViewController {
    public struct Input {
        let username: String
        let userID: String
        let email: String
        let openLink: (String) -> ()
        
        public init(username: String, userID: String, email: String, openLink: @escaping (String) -> Void) {
            self.username = username
            self.userID = userID
            self.email = email
            self.openLink = openLink
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameTitleLabel: UILabel!
    @IBOutlet var nameValueLabel: UILabel!
    @IBOutlet var useridTitleLabel: UILabel!
    @IBOutlet var useridValueLabel: UILabel!
    @IBOutlet var emailTitleLabel: UILabel!
    @IBOutlet var emailValueLabel: UILabel!
    @IBOutlet var privacyImageView: UIImageView!
    @IBOutlet var privacyLabel: UILabel!
    @IBOutlet var termsImageView: UIImageView!
    @IBOutlet var termsLabel: UILabel!
    @IBOutlet var licenceImageView: UIImageView!
    @IBOutlet var licenceLabel: UILabel!
    @IBOutlet var aiPolicyImageView: UIImageView!
    @IBOutlet var aiPolicyLabel: UILabel!
    @IBOutlet var mediaPolicyImageView: UIImageView!
    @IBOutlet var mediaPolicyLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    
    
    // MARK: - Properties
    public var input: Input!
    
    
    // MARK: - Set up
    public override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        useridValueLabel.text = input.userID
        nameValueLabel.text = input.username
        emailValueLabel.text = input.email
//        accountContext?.cach
    }
    
    public override func localize() {
        super.localize()
        
        titleLabel.text = "Infomation".localized
        nameTitleLabel.text = "Infomation.username".localized
        useridTitleLabel.text = "Infomation.userid".localized
        emailTitleLabel.text = "Infomation.email".localized
        privacyLabel.text = "Infomation.privacy".localized
        termsLabel.text = "Infomation.terms".localized
        licenceLabel.text = "Infomation.licence".localized
        aiPolicyLabel.text = "Infomation.aiPolicy".localized
        mediaPolicyLabel.text = "Infomation.mediaPolicy".localized
        versionLabel.text = String(format: "Infomation.version".localized, App.version, App.build)
    }
}


// MARK: Actions
extension ProfileInfoViewController {
    
    @IBAction func policyDidTap() {
        input.openLink("https://ellomessenger.com/privacy-policy")
    }
    
    @IBAction func termsDidTap() {
        input.openLink("https://ellomessenger.com/terms")
    }
    
    @IBAction func licenceDidTap() {
        input.openLink("")
    }
    
    @IBAction func aiPolicyDidTap() {
        input.openLink("https://ellomessenger.com/ai-terms")
    }
    
    @IBAction func mediaPolicyDidTap() {
        input.openLink("")
    }
}
