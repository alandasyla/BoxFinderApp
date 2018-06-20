//
//  MasterViewController.swift
//  BoxFinder
//
//  Created by Alanda Syla on 6/20/18.
//  Copyright © 2018 Alanda Syla. All rights reserved.
//

import UIKit
import RealmSwift

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanQrCode(_:)))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        do {
            self.realm = try Realm()
        } catch {
            
        }
        
        let boxes = self.realm.objects(Box.self)
        
        for box in boxes {
            objects.append(box)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc func insertNewObject(_ sender: Any) {
        let addItemAlert = UIAlertController(title: "Box name", message: nil, preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add", style: .default) { (alertAction: UIAlertAction) in
            if let text = addItemAlert.textFields?.first!.text {
                if text != "" {
                    let box = Box(value: ["name": text, "id": "\(text)\(NSDate())".trimmingCharacters(in: .whitespaces)])
                    try! self.realm.write {
                        self.realm.add(box)
                    }
                    self.objects.append(box)
                    
                    self.tableView.reloadData()
                } else {
                    print("Can't add empty box!!")
                }
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        addItemAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your box name"
        }
        
        addItemAlert.addAction(actionAdd)
        addItemAlert.addAction(actionCancel)
        
        present(addItemAlert, animated: true, completion: nil)
        
    }
    
    //MARK: - QR Code
    
    @objc func scanQrCode(_ sender: Any) {
        
        let qrReaderVC = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeReaderVC") as! QRCodeReaderViewController
        
        qrReaderVC.qrCodeCallBack = { qrCode in
            
            let boxes = self.realm.objects(Box.self)
            
            let firstBoxThatMatchesQrCode = boxes.first(where: {$0.id == qrCode})
            
            if firstBoxThatMatchesQrCode != nil {
                
                self.showBox(with: qrCode)
                
            } else {
                
                let alert = UIAlertController(title: "Not found", message: "There isn't any box with that QR Code", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
                return
            }
        }
        
        self.present(qrReaderVC, animated: true, completion: nil)
    }
    
    func showBox(with qrCode: String) {
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        
        detailVC.boxId = "\(qrCode)".trimmingCharacters(in: .whitespaces)
        detailVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        detailVC.navigationItem.leftItemsSupplementBackButton = true
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Box
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.boxId = "\(object.id)".trimmingCharacters(in: .whitespaces)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = objects[indexPath.row] as! Box
        cell.textLabel!.text = Box(value: object).name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let predicate = NSPredicate(format: "name == %@", Box(value: objects[indexPath.row]).name)
            let boxes = self.realm.objects(Box.self).filter(predicate)
            
            try! self.realm.write {
                if let boxToDelete = boxes.first {
                    self.realm.delete(boxToDelete)
                }
            }
            
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

