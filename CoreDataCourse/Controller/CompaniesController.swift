//
//  ViewController.swift
//  CoreDataCourse
//
//  Created by Лилия on 08.12.2021.
//

import UIKit
import CoreData

class CompaniesController: UIViewController {
    
    // MARK: - Properties
    
    private let companyCellId = "companyCellId"
    private let tableView = UITableView()
    private var companies = [Company]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        navigationItem.title = "Companies"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))
       
        self.companies = coreDataManager.shared.fetchCompanies()
        
        setupNavAppearance()
        setupTableView()
    
    }
    
    // MARK: - Helper Functions
    
    private func setupTableView() {
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: companyCellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .darkBlue
        //tableView.separatorStyle = .none
        tableView.separatorColor = .white
        //tableView.tableFooterView = UIView()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    // MARK: - Selectors
    
    @objc private func handleAddCompany() {
        print("DEBUG: Adding company...")
        let createCompanyController = CreateCompanyController()
        createCompanyController.delegate = self //createCompanyController.companiesController = self
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func handleReset() {
        print("DEBUG: Attemp to delete all Core Dara objects")
        
        let context = coreDataManager.shared.persistentContainer.viewContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        // perform the save
        do {
            try context.execute(batchDeleteRequest)
            
            // upon deletion from core data succeeded
            
            var indexPathToRemove = [IndexPath]()
            
            for (index, _) in companies.enumerated() {
                indexPathToRemove.append(IndexPath(row: index, section: 0))
            }
            
            companies.removeAll()
            tableView.deleteRows(at: indexPathToRemove, with: .left)
            
        } catch let deleteError {
            print("DEBUG: Failed to delete objects from Core Data:", deleteError.localizedDescription)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension CompaniesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "NAME"
        label.backgroundColor = .someBlue
        label.textColor = .darkBlue
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No companies avialable..."
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = .green
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let company = self.companies[indexPath.row]
        
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            // Code I want to do here
            print("DEBUG: Attempting to delete company:", company.name ?? "")
            
            // remove company from our tableView
            self.companies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            // delete the company from Core Data
            let context = coreDataManager.shared.persistentContainer.viewContext
            context.delete(company)
            
            do {
                try context.save()
            }  catch let saveError {
                print("DEBUG: Failed to delete company:", saveError.localizedDescription)
            }
        }
        
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            // Code I want to do here

            boolValue(true) // close swipeActions when action tap
            print("DEBUG: Attempting to edit company:", company.name ?? "")
            
            let editCompanyController = CreateCompanyController()
            editCompanyController.delegate = self
            editCompanyController.company = company
            let navController = CustomNavigationController(rootViewController: editCompanyController)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            
        }
        
        deleteItem.backgroundColor = .lightRed
        editItem.backgroundColor = .darkBlue
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("DEBUG: did select..")
        let company = companies[indexPath.row]
        let employeesController = EmployeesController()
        employeesController.company = company
        navigationController?.pushViewController(employeesController, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension CompaniesController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: companyCellId, for: indexPath) as! CompanyCell
        let company = companies[indexPath.row]
        cell.selectionStyle = .none
        cell.company = company
        return cell
    }
}

// MARK: - CreateCompanyControllerDelegate

extension CompaniesController: CreateCompanyControllerDelegate {
    
    func didAddCompany(company: Company) {
        
        companies.append(company)
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func didEditCompany(company: Company) {
        
        let row = companies.firstIndex(of: company)
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
    }
    
}
