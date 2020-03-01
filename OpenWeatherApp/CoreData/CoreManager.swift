//
//  Created by MAC on 26.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit
import CoreData

class CoreManager: NSObject {
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    static func saveObject(data:String, date:String, icon:String) -> Bool {
        let context = CoreManager.getContext()
        let entity = NSEntityDescription.entity(forEntityName: "HistoryModel", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)
        
        manageObject.setValue(data, forKey: "data")
        manageObject.setValue(date, forKey: "date")
        manageObject.setValue(icon, forKey: "icon")
        
        do {
            try context.save()
            return true
        }catch {
            return false
        }
    }
    
    class func fetchObject() -> [HistoryModel]? {
        let context = CoreManager.getContext()
        var weatherData:[HistoryModel]? = nil
        
        do {
            weatherData = try context.fetch(HistoryModel.fetchRequest())
            return weatherData
        }catch {
            return weatherData
        }
    }
    
}
