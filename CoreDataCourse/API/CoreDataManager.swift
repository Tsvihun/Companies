//
//  CoreDataManager.swift
//  CoreDataCourse
//
//  Created by Лилия on 10.12.2021.
//

import CoreData

struct coreDataManager {
    
    static let shared = coreDataManager() // will live forever as long as your application is still alive, it's properties will too
    
    // initialization of our Core Data Stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ModelData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("DEBUG: Loading of store failed - \(error.localizedDescription)")
            }
        })
        return container
    }()
    
    
    func fetchCompanies() -> [Company] {
        print("DEBUG: Trying to fetch companies..")
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
//        let fetchRequest: NSFetchRequest<Company> = Company.fetchRequest()
//        let fetchRequest = Company.fetchRequest() as NSFetchRequest<Company>
//        let fetchRequest = Company.fetchRequest() // most easy way

        do {
            let companies = try context.fetch(fetchRequest)
            return companies
        } catch let fetchError {
            print("DEBUG: Failed to fetch company:", fetchError.localizedDescription)
            return []
        }
    }
    
    func fetchEmployees() -> [Employee] {
        print("DEBUG: Trying to fetch employees..")
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Employee>(entityName: "Employee")
        
        do {
            let employees = try context.fetch(fetchRequest)
            return employees
        } catch let fetchError {
            print("DEBUG: Failed to fetch employees:", fetchError.localizedDescription)
            return []
        }
    }
    
    
    func createEmployee(employeeName: String, company: Company, birthday: Date, employeeType: String) -> (Employee?, Error?) {
        
        print("DEBUG: Trying to create employee..")
        
        let context = persistentContainer.viewContext
        // create an employee
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee // let employee = Employee(context: context)
        
        employee.setValue(employeeName, forKey: "name") // set name
        employee.setValue(employeeType, forKey: "type") // set name
        
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        employeeInformation.setValue("456", forKey: "taxId") // set taxId
        employeeInformation.setValue(birthday, forKey: "birthday") // set birthday
        
        employee.company = company // set company ( // employee.setValue(company, forKey: "company")
        employee.employeeInformation = employeeInformation // set employeeInformation
        
        // perform the save
        do {
            try context.save()
            return (employee, nil)
        } catch let saveError {
            print("DEBUG: Failed to save employee:", saveError.localizedDescription)
            return (nil, saveError)
        }
    }
}
