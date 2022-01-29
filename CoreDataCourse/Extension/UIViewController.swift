//
//  UIViewController.swift
//  CoreDataCourse
//
//  Created by Лилия on 09.12.2021.
//

import UIKit


extension UIViewController {
    
    func setupNavAppearance() {
        
        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground() // for clarity
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithDefaultBackground() // for clarity
            navBarAppearance.backgroundColor = .lightRed
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barTintColor = .lightRed
            navigationController?.navigationBar.largeTitleTextAttributes = [ .foregroundColor: UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor: UIColor.white]
        }
    }
    
    func setupPlusButtonInNavBar(selector: Selector) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .plus, style: .plain, target: self, action: selector)
    }
    
    func setupCancelButtonInNavBar(selector: Selector) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: selector)
    }
    
}
