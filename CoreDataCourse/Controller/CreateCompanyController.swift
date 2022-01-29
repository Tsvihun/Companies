//
//  CreateCompanyController.swift
//  CoreDataCourse
//
//  Created by Лилия on 09.12.2021.
//

import UIKit
import CoreData

protocol CreateCompanyControllerDelegate {
    func didAddCompany(company: Company)
    func didEditCompany(company: Company)
}

class CreateCompanyController: UIViewController {
    
    // MARK: - Properties
    
    var company: Company? {
        didSet {
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            }
            if let date = company?.founded {
                datePicker.date = date
            }
            nameTextField.text = company?.name
        }
    }
    
    var delegate: CreateCompanyControllerDelegate? //var companiesController: CompaniesController?
    
    lazy var companyImageView: UIImageView = {
        let iv = UIImageView(image: .selectPhoto)
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))) // must use lazy, because now self is nil
        iv.setDemensions(height: 100, width: 100)
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = iv.frame.width / 2
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.darkBlue.cgColor
        iv.layer.borderWidth = 2
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter name"
        return tf
    }()
    
    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.preferredDatePickerStyle = .wheels
        dp.datePickerMode = .date
        return dp
    }()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .darkBlue
        
        setupCancelButtonInNavBar(selector: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        
        setupNavAppearance()
        setupUI()
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        
        let lightBlueBackground = UIView()
        lightBlueBackground.backgroundColor = .someBlue
        view.addSubview(lightBlueBackground)
        lightBlueBackground.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 350)
        
        view.addSubview(companyImageView)
        companyImageView.centerX(inView: view, top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: companyImageView.bottomAnchor, left: view.leftAnchor, paddingLeft: 16, width: 100, height: 50)
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: nameLabel.topAnchor, left: nameLabel.rightAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(datePicker)
        datePicker.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: lightBlueBackground.bottomAnchor, right: view.rightAnchor)
    }
    
    private func createCompany() {
        print("DEBUG: Trying to create company..")
        
        let context = coreDataManager.shared.persistentContainer.viewContext
        
        let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
        company.setValue(nameTextField.text, forKey: "name")
        company.setValue(datePicker.date, forKey: "founded")
        
        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 1)
            company.setValue(imageData, forKey: "imageData")
        }
        
        // perform the save
        do {
            try context.save()
            dismiss(animated: true, completion: {
                self.delegate?.didAddCompany(company: company as! Company) //self.companiesController?.addCompany(company: company as! Company)
            })
        } catch let saveError {
            print("DEBUG: Failed to save company:", saveError.localizedDescription)
        }
    }
    
    private func saveCompanyChanges() {
        print("DEBUG: Trying to save company changes..")
        
        let context = coreDataManager.shared.persistentContainer.viewContext
        company?.name = nameTextField.text
        company?.founded = datePicker.date
        
        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 1)
            company?.imageData = imageData
        }
        
        // perform the save
        do {
            try context.save()
            dismiss(animated: true, completion: {
                self.delegate?.didEditCompany(company: self.company!)
            })
        } catch let saveError {
            print("DEBUG: Failed to save company changes:", saveError.localizedDescription)
        }
        
    }
    
    // MARK: - Selectors
    
    @objc private func handleCancel() {
        print("DEBUG: Cancel to companies..")
        dismiss(animated: true)
    }
    
    @objc private func handleSave() {
       
        if company == nil {
            createCompany()
        } else {
            saveCompanyChanges()
        }
    }
    
    @objc private func handleSelectPhoto() {
        print("DEBUG: Attempt to select Photo..")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CreateCompanyController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let editedImage = info[.editedImage] as? UIImage {
            companyImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            companyImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}
