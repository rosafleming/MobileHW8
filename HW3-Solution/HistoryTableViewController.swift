//
//  HistoryTableViewController.swift
//  HW3-Solution
//
//  Created by Rosa Fleming on 10/29/18.
//  Copyright © 2018 Jonathan Engelsma. All rights reserved.
//

import Foundation
import UIKit

protocol HistoryTableViewControllerDelegate {
    func selectEntry(entry: Conversion)
}


class HistoryTableViewController: UITableViewController {
    var entries : [Conversion]? = [
        Conversion(fromVal: 1, toVal: 1760, mode: .Length, fromUnits: LengthUnit.Miles.rawValue, toUnits:
            LengthUnit.Yards.rawValue, timestamp: Date.distantPast),
        Conversion(fromVal: 1, toVal: 4, mode: .Volume, fromUnits: VolumeUnit.Gallons.rawValue, toUnits:
            VolumeUnit.Quarts.rawValue, timestamp: Date.distantFuture)]
    
    var historyDelegate : HistoryTableViewControllerDelegate?
    var mode : CalculatorMode = .Length {
        didSet {
            switch(mode) {
            case .Length:
                var vals : [String] = []
                for val in LengthUnit.allCases {
                    vals.append(val.rawValue)
                }
            case .Volume:
                var vals : [String] = []
                for val in VolumeUnit.allCases {
                    vals.append(val.rawValue)
                }
            }
        }
    }
    
    var fUnits : String?
    var tUnits: String?
    var fromField : UITextField?
    var toField : UITextField?
    var timeStamp = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortIntoSections(entries: self.entries!)
    }
 
 

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData?[section].entries.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        guard let entry = tableViewData?[indexPath.section].entries[indexPath.row] else {
            return cell
        }
    
        cell.textLabel?.text = "\(entry.fromVal) \(entry.fromUnits) = \(entry.toVal) \(entry.toUnits)"
//        cell.textLabel?.text = entry.toUnits
//        cell.textLabel?.text = String(entry.fromVal)
//        cell.textLabel?.text = String(entry.toVal)
//        cell.textLabel?.text = String(Substring(entry.mode.rawValue))
        cell.detailTextLabel?.text = entry.timestamp.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // use the historyDelegate to report back entry selected to the calculator scene
        if let del = self.historyDelegate {
            let conv = entries![indexPath.row]
            del.selectEntry(entry: conv)
        }
        
        // this pops back to the main calculator
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    var tableViewData: [(sectionHeader: String, entries: [Conversion])]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func sortIntoSections(entries: [Conversion]) {
        
        var tmpEntries : Dictionary<String,[Conversion]> = [:]
        var tmpData: [(sectionHeader: String, entries: [Conversion])] = []
        
        // partition into sections
        for entry in entries {
            let shortDate = entry.timestamp.short
            if var bucket = tmpEntries[shortDate] {
                bucket.append(entry)
                tmpEntries[shortDate] = bucket
            } else {
                tmpEntries[shortDate] = [entry]
            }
        }
 
        
        // breakout into our preferred array format
        let keys = tmpEntries.keys
        for key in keys {
            if let val = tmpEntries[key] {
                tmpData.append((sectionHeader: key, entries: val))
            }
        }
        
        // sort by increasing date.
        tmpData.sort { (v1, v2) -> Bool in
            if v1.sectionHeader < v2.sectionHeader {
                return true
            } else {
                return false
            }
        }
        
        self.tableViewData = tmpData
    }
 
 
}
extension Date {
    struct Formatter {
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
}


