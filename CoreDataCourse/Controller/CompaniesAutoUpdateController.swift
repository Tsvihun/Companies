//
//  CompaniesAutoUpdateController.swift
//  CoreDataCourse
//
//  Created by Лилия on 20.12.2021.
//

import UIKit
import CoreData


class CompaniesAutoUpdateController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let companyCellId = "companyCellId"
    
    lazy var fetchedRC: NSFetchedResultsController<Company> = {
        let fetchRequest = Company.fetchRequest()
        let sortByName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortByName]
        let context = coreDataManager.shared.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self // closure must be lazy for have access to self
        do {
            try frc.performFetch()
        } catch let fetchError {
            print("DEBUG: Perform fetch error:", fetchError.localizedDescription)
        }
        return frc
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        view.backgroundColor = .white
        navigationItem.title = "Companies"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete all", style: .plain, target: self, action: #selector(handleReset))
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))
        setupTableView()
    }
    
    // MARK: - Helper Functions
    private func setupTableView() {
        tableView.register(CompanyCell.self, forCellReuseIdentifier: companyCellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .darkBlue
        tableView.separatorColor = .white
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .white
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - Selectors
    @objc private func handleAddCompany() {
        print("DEBUG: Adding company...")
        let createCompanyController = CreateCompanyController()
        // createCompanyController.delegate = self
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func handleReset() {
        print("DEBUG: Attemp to delete all Core Dara objects")
        
        let context = coreDataManager.shared.persistentContainer.viewContext
        
        let request = Company.fetchRequest()
        
        // perform the fetch
        do {
            let companies = try context.fetch(request)
            companies.forEach { (company) in context.delete(company) }
        } catch let deleteError {
            print("DEBUG: Failed to delete objects from Core Data:", deleteError.localizedDescription)
        }
        
        do {
            try context.save()
        } catch let saveError {
            print("DEBUG: Failed to save changes in Core Data:", saveError.localizedDescription)
        }
        
    }
    
    @objc func handleRefresh() {
//        Service.shared.downloadCompanies()
        tableView.refreshControl?.endRefreshing()
    }
    
}

// MARK: - UITableViewDelegate

extension CompaniesAutoUpdateController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.text = fetchedRC.sectionIndexTitles[section]
        label.backgroundColor = .someBlue
        label.textColor = .darkBlue
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("DEBUG: did select..")
        let employeesController = EmployeesController()
        employeesController.company = fetchedRC.object(at: indexPath)
        navigationController?.pushViewController(employeesController, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension CompaniesAutoUpdateController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedRC.sections![section].numberOfObjects // return fetchedRC.fetchedObjects?.count ?? 0 ????
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: companyCellId, for: indexPath) as! CompanyCell
        cell.company = fetchedRC.object(at: indexPath)
        return cell
    }
    
}

extension CompaniesAutoUpdateController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
}
