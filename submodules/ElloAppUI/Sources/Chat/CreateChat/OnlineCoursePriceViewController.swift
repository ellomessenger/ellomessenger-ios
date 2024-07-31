//
//  OnlineCoursePriceViewController.swift
//  ElloApp
//
//

import UIKit
import ELBase

class OnlineCoursePriceViewController: BaseViewController {
    struct OnlineCourseData {
        var startDate: TimeInterval?
        var endDate: TimeInterval?
        var price: Double?
        
        func isFilled() -> Bool {
            guard let startDate, let endDate, let price else { return false }
            guard startDate < endDate else { return false }
            guard price > 0 else { return false }
            
            return true
        }
    }
    enum DateEditing {
        case none
        case start
        case end
    }
    // MARK: - IBOutlets
    @IBOutlet var priceTextField: SubscriptionChannelPriceTextField!
    @IBOutlet var startDateTextField: UITextField! {
        didSet {
            startDateTextField.inputView = datePickerView
        }
    }
    @IBOutlet var endDateTextField: UITextField! {
        didSet {
            endDateTextField.inputView = datePickerView
        }
    }
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Properties
    private var datePickerView = UIDatePicker()
    private var dateEditing: DateEditing = .none
    private var onlineCourseData = OnlineCourseData()
    var confirmHandled: ((OnlineCourseData) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDatePicker()
        setupToolBar()
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        "CreateChat"
    }
    
    private func setupDatePicker() {
        datePickerView.datePickerMode = .date
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.addTarget(self, action: #selector(handleDateChange), for: .valueChanged)
        datePickerView.backgroundColor = .white
        datePickerView.minimumDate = Date()
        datePickerView.date = Date()//profileObject?.dateOfBirth ?? Date()
    }
    
    private func setupToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItemBtn = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: view,
            action: #selector(UIView.endEditing(_:))
        )
        
        toolBar.setItems([flex, doneItemBtn], animated: false)
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
    }
    
    // MARK: - IBActions
    @IBAction func priceChanged(_ sender: SubscriptionChannelPriceTextField) {
        onlineCourseData.price = sender.text?.double
        updateConfirmButton()
        updatePriceTextField(sender)
    }
    
    @IBAction func beginEditing(_ sender: SubscriptionChannelPriceTextField) {
        updateEditingState()
        updateDateTextFields()
    }
    @IBAction func endEditing(_ sender: SubscriptionChannelPriceTextField) {
        updateEditingState()
    }
    
    @IBAction func swipeDown(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            if sender.velocity(in: view).y > 0 {
                view.endEditing(true)
            }
        default: break
        }
    }
    
    @IBAction private func handleDateChange() {
        let dobDate = datePickerView.date
        switch dateEditing {
        case .none:
            return
        case .start:
            startDateTextField.text = dobDate.stringWithFormat(.MMMddyyyy)
            onlineCourseData.startDate = dobDate.timeIntervalSince1970
        case .end:
            endDateTextField.text = dobDate.stringWithFormat(.MMMddyyyy)
            onlineCourseData.endDate = dobDate.timeIntervalSince1970
        }
        
        if let startDate = onlineCourseData.startDate, let endDate = onlineCourseData.endDate, startDate > endDate {
            onlineCourseData.endDate = nil
            endDateTextField.text = nil
        }
        
        updateConfirmButton()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        confirmHandled?(onlineCourseData)
    }
    
    // MARK: - Actions
    private func updateEditingState() {
        if startDateTextField.isEditing {
            dateEditing = .start
        } else if endDateTextField.isEditing {
            dateEditing = .end
        } else {
            dateEditing = .none
        }
    }
    
    private func updateDateTextFields() {
        if dateEditing == .start {
            datePickerView.minimumDate = Date()
            datePickerView.date = Date(timeIntervalSince1970: onlineCourseData.startDate ?? Date().timeIntervalSince1970)
            if startDateTextField.text?.isEmpty ?? true {
                handleDateChange()
            }
        } else if dateEditing == .end {
            let endMinumumDate = Date(timeIntervalSince1970: onlineCourseData.startDate ?? Date().timeIntervalSince1970)
            datePickerView.minimumDate = endMinumumDate
            datePickerView.date = Date(timeIntervalSince1970: onlineCourseData.endDate ?? endMinumumDate.timeIntervalSince1970)
            if endDateTextField.text?.isEmpty ?? true {
                handleDateChange()
            }
        }
    }
    
    private func updateConfirmButton() {
        confirmButton.isEnabled = onlineCourseData.isFilled()
        confirmButton.isHidden = !confirmButton.isEnabled
        nextButton.isEnabled = onlineCourseData.isFilled()
    }
    
    private func updatePriceTextField(_ sender: SubscriptionChannelPriceTextField) {
        if onlineCourseData.price == nil {
            sender.backgroundColor = UIColor(hex: 0xEEEEEF)
            sender.borderWidth = 0
        } else {
            sender.backgroundColor = .clear
            sender.borderWidth = 1
        }
    }
}

// MARK: - UITextFieldDelegate
extension OnlineCoursePriceViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.shouldPriceChangeCharactersIn(range, replacementString: string)
    }
}

