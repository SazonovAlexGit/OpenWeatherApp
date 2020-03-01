//
//  HistoryViewController.swift
//  OpenWeatherApp
//
//  Created by MAC on 26.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
//MARK: Var, Let and Outlet
    var weatherData = [HistoryModel]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let date = Date()
    let formatter = DateFormatter()
    
    let locationManager = CLLocationManager()
    
    let refreshWeatherControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        formatter.dateFormat = "dd.MM.yyyy"
        
        tableView.refreshControl = refreshWeatherControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        weatherData = CoreManager.fetchObject()!
        tableView.reloadData()
    }
//MARK: TableView Settings
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle==UITableViewCell.EditingStyle.delete {
            let context:NSManagedObjectContext=appDelegate.managedObjectContext
            context.delete(self.weatherData[indexPath.row])
            
            do {
                try context.save()
                self.weatherData.remove(at: indexPath.row)
                tableView.reloadData()
            }catch{
              print("Unexpected error while deleting object: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let coreData = weatherData[indexPath.row]
        
        cell.textLabel!.text = coreData.value(forKey: "data") as? String
        cell.imageView!.image = UIImage (named: (coreData.value(forKey: "icon") as? String)!)
        cell.detailTextLabel!.text = coreData.value(forKey: "date") as? String
        
        return cell
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }
}
