//
//  ListViewController.swift
//  TravelBook
//
//  Created by ismail harmanda on 2.11.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    
    
   var places = [Place]()
    var selectedPlace: Place?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @objc func getPlaces(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Place>(entityName: "Place")
        request.returnsObjectsAsFaults=false
        do{
           try places = context.fetch(request)
            tableView.reloadData()
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = places[indexPath.row].title
        content.secondaryText = places[indexPath.row].subtitle
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = places[indexPath.row]
        goToDetail()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        getPlaces()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onPressAddButton))
        
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func onPressAddButton(){
        performSegue(withIdentifier: "toVC", sender: nil)
    }
    
    func goToDetail(){
        performSegue(withIdentifier: "toVC", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedPlace = nil
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaces), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toVC"){
            let destionVC = segue.destination as! ViewController
            if let safeSelectedPlace = selectedPlace {
                destionVC.selectedLocation = selectedPlace
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let predicate = NSPredicate(format: "id = %@", places[indexPath.row].id! as CVarArg)
            let request = NSFetchRequest<Place>(entityName: "Place")
            request.predicate = predicate
            do{
               let selectedItem = try context.fetch(request)[0]
                context.delete(selectedItem)
                places.remove(at: indexPath.row)
                try context.save()
                tableView.reloadData()
            }catch{
                print(error)
            }
            
        }
        
    }
    
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                let touchPoint = sender.location(in: tableView)
                if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                    // your code here, get the row for the indexPath or do whatever you want
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let selectedItem = self.places[indexPath.row]
                    
                    var titleField = UITextField()
                    var subtitleField = UITextField()
                    titleField.text = selectedItem.title
                    subtitleField.text = selectedItem.subtitle
                    
                    
                    let alert  = UIAlertController(title: "Edit Your Placemark", message: "", preferredStyle:.alert)
                    
                    let confirmAction = UIAlertAction(title: "Edit", style: .default){
                        (action) in
                        // What will happen once the user clicks the Add Item button on our UIAlert
                        selectedItem.title = titleField.text
                        selectedItem.subtitle = subtitleField.text
                        
                        do{
                            try context.save()
                            self.tableView.reloadData()
                        } catch{
                            print(error)
                        }
                        
                       
                  
                        
                        
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                        alert.dismiss(animated: true)
                    }
                  
                    alert.addTextField { alertTextField in
                        alertTextField.placeholder = "Place"
                        alertTextField.text = titleField.text
                        titleField = alertTextField
                        
                    }
                    alert.addTextField { alertTextField in
                        alertTextField.placeholder = "Additional Notes"
                        alertTextField.text = subtitleField.text
                        subtitleField = alertTextField
                    }
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)
                    present(alert,animated:true)
                    
                    
                 
                }
            }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
