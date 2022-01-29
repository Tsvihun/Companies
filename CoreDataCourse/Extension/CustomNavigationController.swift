//
//  CustomNavigationController.swift
//  CoreDataCourse
//
//  Created by Лилия on 09.12.2021.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

