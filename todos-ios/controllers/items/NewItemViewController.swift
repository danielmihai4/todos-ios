//
//  NewItemViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 06/05/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class NewItemViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showDatePicker()
    }

    @IBAction func saveItem(_ sender: Any) {
        var canSave = true
        
        if let listName = nameTextField.text {
            if listName.isEmpty {
                canSave = false
                
                addAlert(title: AlertLabels.nameTitle, message: AlertLabels.nameMessage)
            }
        }
        
        if let dueDate = dueDateTextField.text {
            if dueDate.isEmpty {
                canSave = false
                
                addAlert(title: AlertLabels.dueDateTitle, message: AlertLabels.dueDateMessage)
            }
        }
        
        if canSave {
            performSegue(withIdentifier: Segues.CreateItem, sender: self)
        }
    }
    
    private func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: ButtonLabels.ok, style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    private func showDatePicker() {
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        dueDateTextField.inputAccessoryView = toolbar
        dueDateTextField.inputView = datePicker
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dueDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

}
