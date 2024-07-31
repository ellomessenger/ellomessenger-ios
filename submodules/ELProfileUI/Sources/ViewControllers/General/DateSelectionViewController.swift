//
//  DateSelectionViewController.swift
//  _idx_ELFeedUI_76522291_ios_min11.0
//
//

import UIKit
import ELBase

class DateSelectionViewController: BaseViewController {
    
    // MARK: - Public
    
    var date: Date = Date()
    { willSet{ if newValue != date { setupDate() } }}
    
    var dateChanged: EventClosure<Date>?
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = .clear
        setupDate()
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var datePicker: UIDatePicker?
    
    private func setupDate() {
        datePicker?.date = date
    }
}

extension DateSelectionViewController: UIPickerViewDelegate {
    
    @IBAction private func dateDidChange(_ sender: UIDatePicker?) {
        if let date = sender?.date {
            dateChanged?(date)
        }
    }
}
