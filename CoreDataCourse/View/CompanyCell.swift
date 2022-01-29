//
//  CompanyCell.swift
//  CoreDataCourse
//
//  Created by Лилия on 14.12.2021.
//

import UIKit

class CompanyCell: UITableViewCell {

    // MARK: - Properties
    
    var company: Company? {
        didSet {
            
            if let name = company?.name, let founded = company?.founded {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let date = dateFormatter.string(from: founded)
                
                nameFoundedDateLabel.text = "\(name) - Founded: \(date)"
            } else {
                nameFoundedDateLabel.text = company?.name
            }
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    
    let companyImageView: UIImageView = {
        
        let imageView = UIImageView(image: .selectPhoto)
        imageView.contentMode = .scaleAspectFill
        imageView.setDemensions(height: 40, width: 40)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.darkBlue.cgColor
        imageView.layer.borderWidth = 0.5
    
        return imageView
    }()
    
    let nameFoundedDateLabel: UILabel = {
        
        let label = UILabel()
        label.text = "COMPANY NAME"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .lightBlue
        
        addSubview(companyImageView)
        companyImageView.centerY(inView: self, left: leftAnchor, paddingLeft: 16)
        
        addSubview(nameFoundedDateLabel)
        nameFoundedDateLabel.centerY(inView: self, left: companyImageView.rightAnchor, paddingLeft: 8, right: rightAnchor, paddingRight: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
