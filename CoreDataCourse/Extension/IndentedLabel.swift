//
//  IndentedLabel.swift
//  CoreDataCourse
//
//  Created by Лилия on 16.12.2021.
//

import UIKit

class IndentedLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insents = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insents)
        super.drawText(in: customRect)
    }

}
