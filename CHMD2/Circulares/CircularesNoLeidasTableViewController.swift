//
//  CircularesNoLeidasTableViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/26/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class CircularesNoLeidasTableViewController: UITableViewController {
    @IBOutlet var tableCirculares: UITableView!
    var circulares = [Circular]()
    var db: OpaquePointer?
       var idUsuario:String=""
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    var leerMetodo:String="leerCircular.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circulares.removeAll()
        
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
       
        if(ConexionRed.isConnectedToNetwork()){
           let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
            let _url = URL(string: address);
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
            as! CircularNoLeidaTableViewCell
        let c = circulares[indexPath.row]
        cell.lblEncabezado.text? = "Circular No. \(c.id)"
        cell.lblTitulo.text? = c.nombre.uppercased()
        cell.lblFecha.text? = c.fecha
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favAction = self.contextualFavAction(forRowAtIndexPath: indexPath)
        let eliminaAction = self.contextualDelAction(forRowAtIndexPath: indexPath)
        let leerAction = self.contextualReadAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [eliminaAction,leerAction,favAction])
        return swipeConfig
    }
    
    func contextualFavAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // 1
        let circular = circulares[indexPath.row]
        // 2
        let action = UIContextualAction(style: .normal,
                                        title: "Favorita") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let idCircular:String = "\(circular.id)"
                                            
                                            self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: idCircular)
                                            
                                            //self.tableViewCirculares.reloadRows(at: [indexPath], with: .none)
                                           let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
                                              let _url = URL(string: address);
                                            self.obtenerCirculares(uri:address)
                                            
            
        }
        // 7
        action.image = UIImage(named: "favIcon")
        action.backgroundColor = UIColor.blue
        
        return action
    }
    
    
    
    func contextualReadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
           // 1
           let circular = circulares[indexPath.row]
           // 2
           let action = UIContextualAction(style: .normal,
                                           title: "Compartida") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                                let idCircular:String = "\(circular.id)"
                                                                                         
                                            self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: idCircular)
                                                let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
                                               let _url = URL(string: address);
                                               self.obtenerCirculares(uri:address)
                                               
               
           }
           // 7
           action.image = UIImage(named: "readIcon")
        action.backgroundColor = UIColor.green
           
           return action
       }
    
    func contextualDelAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // 1
        let circular = circulares[indexPath.row]
        // 2
        let action = UIContextualAction(style: .normal,
                                        title: "Eliminada") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let idCircular:String = "\(circular.id)"
                                            
                                            self.delCircular(direccion: self.urlBase+"eliminarCircular.php", usuario_id: self.idUsuario, circular_id: idCircular)
                                            
                                            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
                                              let _url = URL(string: address);
                                           
                                            self.obtenerCirculares(uri:address)
                                            
            
        }
        // 7
        action.image = UIImage(named: "delIcon")
        action.backgroundColor = UIColor.red
        
        return action
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
    
    
    func obtenerCirculares(uri:String){
           self.circulares.removeAll()
           Alamofire.request(uri)
               .responseJSON { response in
                   // check for errors
                   guard response.result.error == nil else {
                       // got an error in getting the data, need to handle it
                       print("error en la consulta")
                       print(response.result.error!)
                       return
                   }
                   /*
                    [{"id":"1008","titulo":"\u00a1Felices vacaciones!","estatus":"Enviada","ciclo_escolar_id":"4","created_at":"2019-04-12 13:02:19","updated_at":"2019-04-12 13:02:19","leido":"1","favorito":"1","compartida":"1","eliminado":"1","status_envio":null,"envio_todos":"0"},
                    */
                   
                   if let diccionarios = response.result.value as? [Dictionary<String,AnyObject>]{
                       for diccionario in diccionarios{
                           //print(diccionario)
                           
                           guard let id = diccionario["id"] as? String else {
                               print("No se pudo obtener el id")
                               return
                           }
                           print(id)
                           
                           guard let titulo = diccionario["titulo"] as? String else {
                               print("No se pudo obtener el titulo")
                               return
                           }
                           
                           guard let fecha = diccionario["created_at"] as? String else {
                               print("No se pudo obtener la fecha")
                               return
                           }
                           
                           var imagen:UIImage
                           imagen = UIImage.init(named: "appmenu05")!
                           
                           
                           guard let leido = diccionario["leido"] as? String else {
                               return
                           }
                           
                           guard let favorito = diccionario["favorito"] as? String else {
                               return
                           }
                           
                           
                           guard let eliminada = diccionario["eliminado"] as? String else {
                               return
                           }
                           
                           guard let texto = diccionario["contenido"] as? String else {
                               return
                           }
                           
                           
                           var noLeida:Int = 0
                           if(Int(leido)! == 0){
                               noLeida = 1
                            self.circulares.append(Circular(id:Int(id)!,encabezado: "",nombre: titulo,fecha: fecha,contenido: ""))
                                                   
                           }
                           
                                                   
                           //Guardar las circulares
                        
                       }
                       
                       self.tableCirculares.reloadData()
                   }
                   
                   
               
           
       }
   
    }
    
   
    
    
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
                      
                       self.circulares.append(Circular(id:Int(id),encabezado: "",nombre: titulo,fecha: fechaCircular,contenido:cont))
                    }
                  
                  self.tableCirculares.reloadData()

                   }
                  else {
                   print("SELECT statement could not be prepared")
                 }

                 sqlite3_finalize(queryStatement)
             }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let c = circulares[indexPath.row]
        
        UserDefaults.standard.set(c.id,forKey:"id")
        UserDefaults.standard.set(c.nombre,forKey:"nombre")
        UserDefaults.standard.set(c.contenido,forKey:"contenido")
        UserDefaults.standard.set(0, forKey: "viaNotif")
        performSegue(withIdentifier: "NLcircularSegue", sender:self)
        
    }
    
    
    
    func favCircular(direccion:String, usuario_id:String, circular_id:String){
           let parameters: Parameters = ["usuario_id": usuario_id, "circular_id": circular_id]      //This will be your parameter
            Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
               switch (response.result) {
               case .success:
                   print(response)
                   break
               case .failure:
                   print(Error.self)
               }
           }
       }
       
       
       func leerCircular(direccion:String, usuario_id:String, circular_id:String){
              let parameters: Parameters = ["usuario_id": usuario_id, "circular_id": circular_id]      //This will be your parameter
              Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
                  switch (response.result) {
                  case .success:
                      print(response)
                      break
                  case .failure:
                      print(Error.self)
                  }
              }
          }
       
    func delCircular(direccion:String, usuario_id:String, circular_id:String){
        let parameters: Parameters = ["usuario_id": usuario_id, "circular_id": circular_id]      //This will be your parameter
        Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
            switch (response.result) {
            case .success:
                print(response)
                break
            case .failure:
                print(Error.self)
            }
        }
    }
    
}
