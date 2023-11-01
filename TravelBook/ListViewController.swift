//
//  ListViewController.swift
//  TravelBook
//
//  Created by ismail harmanda on 2.11.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
   var places = [Place]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func getPlaces(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Place>(entityName: "Place")
        request.returnsObjectsAsFaults=false
        do{
           try places = context.fetch(request)
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
        cell.contentConfiguration = content
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlaces()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onPressAddButton))
        
    }
    
    @objc func onPressAddButton(){
        performSegue(withIdentifier: "toVC", sender: nil)
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
