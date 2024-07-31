//
//  AlertViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 18/2/23.
//

import UIKit

public class AlertViewController {
    public static func createAlertControllerWithImage(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction], image: UIImage?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
//        alertController.setBackgroundColor(color: .)
        alertController.setMessage(font: .systemFont(ofSize: 16, weight: .regular), color: UIColor(hexString: "#070708"))

        for action in actions {
            alertController.addAction(action)
        }

        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            let imageSize = CGSize(width: 240, height: 120)
            let imageContainer = UIView(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
            imageView.frame = imageContainer.bounds
            imageContainer.addSubview(imageView)
            alertController.view.addSubview(imageContainer)
            imageContainer.translatesAutoresizingMaskIntoConstraints = false
            imageContainer.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
            imageContainer.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
            imageContainer.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor).isActive = true
            imageContainer.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 70).isActive = true
        }
        
        return alertController
    }
    
    public static func createAlertControllerWithTopImage(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction], image: UIImage?) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)

        alertController.setBackgroundColor(color: UIColor(red: 0.933, green: 0.933, blue: 0.937, alpha: 1))
        alertController.setMessage(font: .systemFont(ofSize: 16, weight: .regular), color: UIColor(hexString: "#070708"))

        if let image = image {
            let imageSize = CGSize(width: 42, height: 42)

            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit

            let imageContainer = UIView()
            imageContainer.addSubview(imageView)
            alertController.view.addSubview(imageContainer)
            imageContainer.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageContainer.heightAnchor.constraint(equalToConstant: imageSize.height),
                imageContainer.widthAnchor.constraint(equalToConstant: imageSize.width),
                imageContainer.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
                imageContainer.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20)
            ])

            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor)
            ])

            if let title = title {
                let titleLabel = UILabel()
                titleLabel.text = title
                titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
                titleLabel.textAlignment = .center
                alertController.view.addSubview(titleLabel)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 16),
                    titleLabel.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
                    titleLabel.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16)
                ])

                if let message = message {
                    let messageLabel = UILabel()
                    messageLabel.text = message
                    messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
                    messageLabel.textAlignment = .center
                    messageLabel.numberOfLines = 0
                    alertController.view.addSubview(messageLabel)
                    messageLabel.translatesAutoresizingMaskIntoConstraints = false

                    NSLayoutConstraint.activate([
                        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                        messageLabel.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
                        messageLabel.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16)
                    ])
                }
            }

            alertController.view.heightAnchor.constraint(equalToConstant: 270).isActive = true
            alertController.view.widthAnchor.constraint(equalToConstant: 270).isActive = true
        }

        for action in actions {
            alertController.addAction(action)
        }

        return alertController
    }

    
    public static func createOkAlertController(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        let alertController = AlertViewController.createAlertControllerWithImage(
            title: title,
            message: message,
            preferredStyle: .alert,
            actions: [okAction],
            image: nil
        )
        
        return alertController
    }
}


public extension UIAlertController {
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    func setTitlet(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setMessage(font: UIFont?, color: UIColor?) {
            guard let message = self.message else { return }
            let attributeString = NSMutableAttributedString(string: message)
            if let messageFont = font {
                attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                              range: NSMakeRange(0, message.utf8.count))
            }

            if let messageColorColor = color {
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                              range: NSMakeRange(0, message.utf8.count))
            }
            self.setValue(attributeString, forKey: "attributedMessage")
        }
       
}
