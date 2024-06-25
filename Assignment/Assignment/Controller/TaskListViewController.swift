//
//  TaskListViewController.swift
//  Assignment
//
//  Created by Atul Upadhyay on 25/06/24.
//

import UIKit
import UserNotifications

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tasks = [Task]()
    var filteredTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        loadTasks()
        filteredTasks = tasks
        
    }
    
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let taskDetailVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        taskDetailVC.delegate = self
        self.present(taskDetailVC, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSection = 1
        let noDataLbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        if filteredTasks.isEmpty {
            noDataLbl.text = "No task found"
        } else {
            noDataLbl.text = ""
        }
        noDataLbl.textColor = UIColor.lightGray
        noDataLbl.textAlignment = .center
        tableView.backgroundView = noDataLbl
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
        let task = filteredTasks[indexPath.row]
        
        cell.titleLabel.text = task.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        cell.dueDateLabel.text = dateFormatter.string(from: task.dueDate)
        cell.completedSwitch.isOn = task.isCompleted
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let taskDetailVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        taskDetailVC.task = filteredTasks[indexPath.row]
        taskDetailVC.delegate = self
        self.present(taskDetailVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.removeAll { $0.title == filteredTasks[indexPath.row].title }
            filteredTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveTasks()
        }
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
    
    // MARK: - Persistent Storage
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let savedTasks = UserDefaults.standard.object(forKey: "tasks") as? Data {
            if let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
                tasks = decodedTasks
            }
        }
    }
}

extension TaskListViewController: TaskDetailViewControllerDelegate {
    func didSaveTask(_ task: Task) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tasks[selectedIndexPath.row] = task
            filteredTasks[selectedIndexPath.row] = task
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            tasks.append(task)
            filteredTasks.append(task)
            tableView.reloadData()
        }
        saveTasks()
    }
}
