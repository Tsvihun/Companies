//
//  CreateEmployeeController.swift
//  CoreDataCourse
//
//  Created by Лилия on 14.12.2021.
//

import UIKit
import CoreData

protocol CreateEmployeeControllerDelegate {
    func didAddEmployee(employee: Employee)
    func didEditEmployee(employee: Employee)
}

class CreateEmployeeController: UIViewController {
    
    // MARK: - Properties
    
    var company: Company?
    
    var delegate: CreateEmployeeControllerDelegate?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .darkBlue
        return label
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter name"
        tf.textColor = .darkBlue
        return tf
    }()
    
    let birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Birthday"
        label.textColor = .darkBlue
        return label
    }()
    
    let birthdayTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "MM/DD/YYYY"
        tf.textColor = .darkBlue
        return tf
    }()
    
    let employeeTypeSegmentedControl: UISegmentedControl = {
        
        let types = [EmployeeType.Executive.rawValue, EmployeeType.SeniorManagement.rawValue, EmployeeType.Staff.rawValue]
        
        let sc = UISegmentedControl(items: types)
    
        sc.setTitleTextAttributes( [.foregroundColor : UIColor.someBlue], for: .selected)
        sc.setTitleTextAttributes( [.foregroundColor : UIColor.darkBlue], for: .normal)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .darkBlue
        sc.layer.borderColor = UIColor.darkBlue.cgColor
        sc.layer.borderWidth = 0.5
        
        return sc
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Create Employee"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .darkBlue
        
        setupCancelButtonInNavBar(selector: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        setupUI()
        
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        
        let lightBlueBackground = UIView()
        lightBlueBackground.backgroundColor = .someBlue
        view.addSubview(lightBlueBackground)
        lightBlueBackground.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 150)
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16, width: 100, height: 50)
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: nameLabel.topAnchor, left: nameLabel.rightAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor, paddingRight: 16)
        
        view.addSubview(birthdayLabel)
        birthdayLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, width: 100, height: 50)
        
        view.addSubview(birthdayTextField)
        birthdayTextField.anchor(top: birthdayLabel.topAnchor, left: birthdayLabel.rightAnchor, bottom: birthdayLabel.bottomAnchor, right: nameTextField.rightAnchor)
        
        view.addSubview(employeeTypeSegmentedControl)
        employeeTypeSegmentedControl.anchor(top: birthdayLabel.bottomAnchor, left: birthdayLabel.leftAnchor, right: nameTextField.rightAnchor, paddingTop: 0, height: 34)
        
    }
    
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Selectors
    
    @objc private func handleCancel() {
        print("DEBUG: Cancel to employees..")
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
        
        guard let company = company else { return }
        guard let employeeName = nameTextField.text else { return }
        guard let birthdayText = birthdayTextField.text else { return }
        
        // let's perform validation the validaton step here
        if birthdayText.isEmpty {
            showError(title: "Empty Birthday", message: "You have not entered a birthday.")
            return
        }
        //
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let birthdayDate = dateFormatter.date(from: birthdayText) else {
            showError(title: "Bad Date", message: "Birthday date entered not valid.")
            return
        }
        
        guard let employeeType = employeeTypeSegmentedControl.titleForSegment(at: employeeTypeSegmentedControl.selectedSegmentIndex) else { return }
        
        let tuple = coreDataManager.shared.createEmployee(employeeName: employeeName, company: company, birthday: birthdayDate, employeeType: employeeType)
        if tuple.1 != nil {
            //present an error modal of some kind like perhaps use a UIAlertController to show error message
            
        } else {
            //creation success
            dismiss(animated: true, completion: {
                self.delegate?.didAddEmployee(employee: tuple.0!)
            })
        }
    }
    
}
