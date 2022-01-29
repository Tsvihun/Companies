//
//  Service.swift
//  CoreDataCourse
//
//  Created by Лилия on 20.12.2021.
//

import Foundation
import CoreData

struct Service {
    
    static let shared = Service()
    
    func downloadCompanies() {
        print("DEBUG: Attempting to download companies...")
        
        guard let url = URL(string: "https://api.letsbuildthatapp.com/intermediate_training/companies") else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("DEBUG: Failed to download companies:", error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let jsonCompanies = try JSONDecoder().decode([JSONCompany].self, from: data)
                
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateContext.parent = coreDataManager.shared.persistentContainer.viewContext
                
                jsonCompanies.forEach { (jsonCompany) in
                    let company = Company(context: privateContext)
                    company.name = jsonCompany.name // set name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let foundedDate = dateFormatter.date(from: jsonCompany.founded ?? "")
                    company.founded = foundedDate // set founded date
                    
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        let employee = Employee(context: privateContext)
                        employee.company = company
                        employee.name = jsonEmployee.name
                        employee.type = jsonEmployee.type
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        
                        let birthdaydDate = dateFormatter.date(from: jsonEmployee.birthday)
                        employeeInformation.birthday = birthdaydDate
                        
                        employee.employeeInformation = employeeInformation
                    })
                    
                    do {
                        try privateContext.save()
                        try privateContext.parent?.save()
                    } catch let saveError {
                        print("DEBUG: Failed to save companies:", saveError)
                    }
                    
                }
                
            } catch let decodeError {
                print("DEBUG: Failed to decode data:", decodeError)
            }
            
        }).resume()
    }
}
