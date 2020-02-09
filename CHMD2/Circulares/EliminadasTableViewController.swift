//
//  EliminadasTableViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 12/6/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3


class EliminadasTableViewController: UITableViewController {
     @IBOutlet var tableCirculares: UITableView!
        var circulares = [Circular]()
        var db: OpaquePointer?
       var idUsuario:String=""
    
        override func viewDidLoad() {
            super.viewDidLoad()
            circulares.removeAll()
            idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
            
            if(ConexionRed.isConnectedToNetwork()){
            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesEliminadas.php?usuario_id=\(idUsuario)"
            self.obtenerCirculares(uri: address)
            }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Se muestran las últimas circulares registradas", delegate: nil, cancelButtonTitle: "Aceptar")
                       alert.show()
                self.leerCirculares()
                
            }
            
            
          
          
            
        }
        
        // MARK: - Table view data source
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return circulares.count
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
                as! CircularCompartidaTableViewCell
            let c = circulares[indexPath.row]
            cell.lblEncabezado.text? = "Circular No. \(c.id)"
            cell.lblTitulo.text? = c.nombre.uppercased()
            var horaFecha = c.fecha.split{$0 == " "}.map(String.init)
            cell.lblFecha.text? = horaFecha[0]
            cell.lblHora.text? = horaFecha[1]
            
            return cell
            
        }
        
        
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
        
       func leerCirculares(){
               
               let fileUrl = try!
                          FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
               
               if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
                   print("error opening database")
               }
               
                  let consulta = "SELECT * FROM appCircular WHERE idUsuario=\(self.idUsuario) AND eliminada=1;"
                  var queryStatement: OpaquePointer? = nil
               var imagen:UIImage
               imagen = UIImage.init(named: "appmenu05")!
               
               if sqlite3_prepare_v2(db, consulta, -1, &queryStatement, nil) == SQLITE_OK {
              
                   
                   
                    while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                            let id = sqlite3_column_int(queryStatement, 0)
                               var titulo:String="";
                       
                              if let name = sqlite3_column_text(queryStatement, 2) {
                                  titulo = String(cString: name).uppercased()
                                 } else {
                                  print("name not found")
                              }
                       
                       
                               var cont:String="";
                       
                              if let contenido = sqlite3_column_text(queryStatement, 3) {
                                  cont = String(cString: contenido)
                                 } else {
                                  print("name not found")
                              }
                       
                               let leida = sqlite3_column_int(queryStatement, 5)
                               let favorita = sqlite3_column_int(queryStatement, 6)
                               let eliminada = sqlite3_column_int(queryStatement, 8)
                               if(Int(leida)>0){
                                  imagen = UIImage.init(named: "leidas_azul")!
                                }
                                //No leídas
                                if(Int(leida)==0){
                                   imagen = UIImage.init(named: "noleidas_celeste")!
                                 }
                               if(Int(favorita)>0){
                                  imagen = UIImage.init(named: "appmenu06")!
                                 }
                               var noLeida:Int = 0
                               if(Int(leida) == 0){
                                   noLeida = 1
                                  }
                       var fechaCircular="";
                       if let fecha = sqlite3_column_text(queryStatement, 9) {
                           fechaCircular = String(cString: fecha).uppercased()
                          } else {
                           print("name not found")
                       }
                       
                        self.circulares.append(Circular(id:Int(id),encabezado: "",nombre: titulo,fecha: fechaCircular,contenido:""))
                     }
                   
                   self.tableCirculares.reloadData()

                    }
                   else {
                    print("SELECT statement could not be prepared")
                  }

                  sqlite3_finalize(queryStatement)
              }
        
        
        
       func obtenerCirculares(uri:String){
              Alamofire.request(uri)
                  .responseJSON { response in
                      // check for errors
                      guard response.result.error == nil else {
                          // got an error in getting the data, need to handle it
                          print("error en la consulta")
                          print(response.result.error!)
                          return
                      }
                      
                      
                      if let diccionarios = response.result.value as? [Dictionary<String,AnyObject>]{
                          for diccionario in diccionarios{
                              print(diccionario)//print each of the dictionaries
                              
                              guard let id = diccionario["id"] as? String else {
                                  print("No se pudo obtener el id")
                                  return
                              }
                              
                              guard let titulo = diccionario["titulo"] as? String else {
                                  print("No se pudo obtener el titulo")
                                  return
                              }
                              
                              guard let fecha = diccionario["created_at"] as? String else {
                                  print("No se pudo obtener la fecha")
                                  return
                              }
                              
                              
                            self.circulares.append(Circular(id:Int(id)!,encabezado: "",nombre: titulo,fecha: fecha,contenido: ""))
                              
                              
                          }
                          
                          self.tableCirculares.reloadData()
                      }
                      
                      
              }
              
          }
        
        
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let c = circulares[indexPath.row]
            
            UserDefaults.standard.set(c.id,forKey:"id")
            UserDefaults.standard.set(c.nombre,forKey:"nombre")
            UserDefaults.standard.set(c.contenido,forKey:"contenido")
            UserDefaults.standard.set(0, forKey: "viaNotif")
            performSegue(withIdentifier: "CcircularSegue", sender:self)
            
        }
        
    }
