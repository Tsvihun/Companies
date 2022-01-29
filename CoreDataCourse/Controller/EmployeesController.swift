//
//  EmployeesController.swift
//  CoreDataCourse
//
//  Created by Лилия on 14.12.2021.
//

import UIKit
import CoreData

class EmployeesController: UIViewController {
    
    // MARK: - Properties
    private let employeeCellId = "employeeCellId"
    private let tableView = UITableView()
    var company: Company?
    private var allEmployees = [[Employee]]()
    private let EmployeeTypes = [EmployeeType.Executive.rawValue, EmployeeType.SeniorManagement.rawValue, EmployeeType.Staff.rawValue]
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company?.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupPlusButtonInNavBar(selector: #selector(handleAdd))
        fetchEmployees()
        setupTableView()
        
    }
    
    // MARK: - Helper Functions
    
    private func fetchEmployees() {
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return }
        
        // filtering employees
//        let executive = companyEmployees.filter {$0.type == EmployeeType.Executive.rawValue}
//        let seniorManagement = companyEmployees.filter {$0.type == EmployeeType.SeniorManagement.rawValue}
//        let staff = companyEmployees.filter {$0.type == EmployeeType.Staff.rawValue}
//        allEmployees = [executive, seniorManagement, staff]
        
        // another way to filtering employees
        allEmployees = []
        EmployeeTypes.forEach { EmployeeType in
            allEmployees.append(companyEmployees.filter {$0.type == EmployeeType} )
        }
        
    }
    
    private func setupTableView() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: employeeCellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .darkBlue
        tableView.separatorColor = .white
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    // MARK: - Selectors
    
    @objc func handleAdd() {
        print("DEBUG: Trying to add an employee..")
        
        let createEmployeeController = CreateEmployeeController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        let navController = CustomNavigationController(rootViewController: createEmployeeController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        
    }
    
}

// MARK: - UITableViewDelegate

extension EmployeesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.backgroundColor = .someBlue
        label.textColor = .darkBlue
        label.font = .boldSystemFont(ofSize: 16)
        label.text = EmployeeTypes[section]
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

// MARK: - UITableViewDataSource

extension EmployeesController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmployees[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: employeeCellId, for: indexPath)
        let employee = allEmployees[indexPath.section][indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let name = employee.name ?? ""
        let date = dateFormatter.string(from: employee.employeeInformation?.birthday ?? Date())
        
        cell.textLabel?.text = "\(name) \(date)"
        
        cell.backgroundColor = .lightBlue
        cell.selectionStyle = .none
        return cell
    }
    
}

extension EmployeesController: CreateEmployeeControllerDelegate {
    
    func didAddEmployee(employee: Employee) {
        
        
        guard let section = EmployeeTypes.firstIndex(of: employee.type!) else { return }
        allEmployees[section].append(employee)
        
        let row = allEmployees[section].count - 1
        
        let newIndexPath = IndexPath(row: row, section: section)
        tableView.insertRows(at: [newIndexPath], with: .middle)
    }
    
    func didEditEmployee(employee: Employee) {
    }
    
}
