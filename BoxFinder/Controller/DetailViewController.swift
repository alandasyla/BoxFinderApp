//
//  DetailViewController.swift
//  BoxFinder
//
//  Created by Alanda Syla on 6/20/18.
//  Copyright © 2018 Alanda Syla. All rights reserved.
//

import UIKit
import RealmSwift

class DetailViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var boxId: String!
    var realm: Realm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QR Code
        let qrCodeButton = UIBarButtonItem(image: UIImage(named: "qr_code"), style: .plain, target: self, action: #selector(showQrCode(_:)))
        navigationItem.leftBarButtonItem = qrCodeButton
        
        // Add
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        // Split VC
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Realm
        do {
            self.realm = try Realm()
        } catch {
            
        }
        
        let predicate = NSPredicate(format: "boxId == %@", boxId)
        let items = self.realm.objects(Item.self).filter(predicate)
        
        for item in items {
            objects.append(item)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc func showQrCode(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showQRCodeSegue", sender: nil)
    }
    
    @objc func insertNewObject(_ sender: Any) {
        let addItemAlert = UIAlertController(title: "Add item on the box", message: nil, preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add Item", style: .default) { (alertAction: UIAlertAction) in
            if let text = addItemAlert.textFields?.first?.text {
                let item = Item(value: ["name": text, "boxId": self.boxId])
                try! self.realm.write {
                    self.realm.add(item)
                    self.objects.append(item)
                }
                self.tableView.reloadData()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Don't add item", style: .cancel) { (alertAction: UIAlertAction) in
            
        }
        
        
        addItemAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter your item name"
        }
        
        addItemAlert.addAction(actionAdd)
        addItemAlert.addAction(actionCancel)
        
        present(addItemAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQRCodeSegue" {
            
            let qrCodeViewController = segue.destination as! QRCodeGeneratorViewController
            qrCodeViewController.boxId = boxId
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
        
        let object = objects[indexPath.row] as! Item
        cell.textLabel!.text = object.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}
