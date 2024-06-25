//
//  TaskModel.swift
//  Assignment
//
//  Created by Atul Upadhyay on 25/06/24.
//

import Foundation

struct Task: Codable {
    var title: String
    var dueDate: Date
    var isCompleted: Bool
}

