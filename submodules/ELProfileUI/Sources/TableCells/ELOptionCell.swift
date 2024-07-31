//
//  ELCountryCell.swift
//  _idx_ELWelcomeUI_47830975_ios_min11.0
//
//

import UIKit

class ELOptionCell: UITableViewCell {
    @IBOutlet private weak var iconIV: UIImageView?
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var flagLabel: UILabel?
    
    private var dataTask: URLSessionDataTask?
    
    var title: String? {
        didSet {
            titleL?.text = title
            titleL?.textColor = UIColor(hexString: "#070708")
        }
    }
    
    var icon: UIImage? {
        didSet{
            iconIV?.image = icon
            iconIV?.isHidden = icon == nil
        }
    }
    
    var iconUrl: URL? {
        didSet {
            guard let icon = iconUrl  else { return }
            dataTask = URLSession.shared.dataTask(with: URLRequest(url: icon)) { [weak self] data, resp, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.iconIV?.image = UIImage(data: data)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    override func prepareForReuse() {
        dataTask?.cancel()
    }
    
    func configure(title: String?, icon: UIImage?, iconUrl: URL?) {
        self.title = title
        self.icon = icon
        self.iconUrl = iconUrl
    }
    
    func configure(title: String?, iconUrl: URL?, flagName: String?) {
        self.title = title
        iconIV?.isHidden = true
        flagLabel?.isHidden = false
        
        if let flagName {
            flagLabel?.text = flag(country: flagName)
        }
    }
    
    /// Get flag emoji by country code
    private func flag(country:String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
