//
//  MenuCircularesTableViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 4/7/20.
//  Copyright © 2020 Rafael David Castro Luna. All rights reserved.
//

import UIKit

class MenuCircularesTableViewController: UITableViewController {

    @IBOutlet var tableViewMenu: UITableView!
     var menu = [MenuCirculares]()
    override func viewDidLoad() {
        super.viewDidLoad()

          menu.append(MenuCirculares(id: 1, nombre: "Entrada", imagen:#imageLiteral(resourceName: "appmenu03")))
          menu.append(MenuCirculares(id: 2, nombre: "Favoritos", imagen:#imageLiteral(resourceName: "appmenu06")))
          menu.append(MenuCirculares(id: 3, nombre: "No leídos", imagen:#imageLiteral(resourceName: "appmenu05")))
          menu.append(MenuCirculares(id: 4, nombre: "Papelera", imagen:#imageLiteral(resourceName: "appmenu07")))
          menu.append(MenuCirculares(id: 5, nombre: "Menú principal", imagen:#imageLiteral(resourceName: "appmenu09")))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menu.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let valor = menu[indexPath.row]
           
        if (valor.id==1){
            performSegue(withIdentifier: "circularesSegue", sender: self)
        }
        if (valor.id==2){
            performSegue(withIdentifier: "favSegue", sender: self)
        }
        if (valor.id==3){
            performSegue(withIdentifier: "noLeidasSegue", sender: self)
        }
        if (valor.id==4){
            performSegue(withIdentifier: "eliminadasSegue", sender: self)
        }
        if (valor.id==5){
              self.performSegue(withIdentifier: "unwindToPrincipal", sender: self)
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
           as! MenuCircularTableViewCell
           let m = menu[indexPath.row]
           cell.lblMenu.text?=m.nombre
            cell.imgMenu.image=m.imagen
        
        return cell
    }
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}