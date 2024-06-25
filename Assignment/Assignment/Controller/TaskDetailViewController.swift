//
//  TaskDetailViewController.swift
//  Assignment
//
//  Created by Atul Upadhyay on 25/06/24.
//

import UIKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didSaveTask(_ task: Task)
}

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var completedSwitch: UISwitch!
    
    var task: Task?
    weak var delegate: TaskDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task {
            titleTextField.text = task.title
            datePicker.date = task.dueDate
            completedSwitch.isOn = task.isCompleted
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        titleTextField.backgroundColor = .clear
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your Task", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        titleTextField.leftView = paddingView
        titleTextField.leftViewMode = .always
        titleTextField.rightView = paddingView
        titleTextField.rightViewMode = .always
        titleTextField.layer.cornerRadius = 30.0
        titleTextField.layer.masksToBounds = true
        titleTextField.layer.borderColor = (UIColor.black).cgColor
        titleTextField.layer.borderWidth = 1.0
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert("Task name cannot be empty.")
            return
        }
        let dueDate = datePicker.date
        let isCompleted = completedSwitch.isOn
        let task = Task(title: title, dueDate: dueDate, isCompleted: isCompleted)
        delegate?.didSaveTask(task)
        scheduleNotification(for: task)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.title, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

