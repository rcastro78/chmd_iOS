//
//  CircularTableViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/23/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3



extension CircularTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    // TODO
  }
}

class CircularTableViewController: UITableViewController,UISearchBarDelegate {
    @IBOutlet var tableViewCirculares: UITableView!
    @IBOutlet weak var barBusqueda: UISearchBar!
    var buscando=false
    var circulares = [CircularTodas]()
    var db: OpaquePointer?
    var idUsuario:String=""
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    var noleerMetodo:String="noleerCircular.php"
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circulares.removeAll()
        self.hideKeyboardWhenTappedAround()
        barBusqueda.delegate = self
        
        
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
        //idUsuario="1944"
         
        if ConexionRed.isConnectedToNetwork() == true {
            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
              let _url = URL(string: address);
            self.obtenerCirculares(uri:address)
            
        } else {
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Se muestran las últimas circulares registradas", delegate: nil, cancelButtonTitle: "Aceptar")
            alert.show()
            
            print("Leer desde la base")
            self.leerCirculares()
            
        }
        
        
      
        
        
        //self.limpiarCirculares()
        
        //self.guardarCirculares(idCircular: 1, idUsuario: 1944, nombre: "TEST...", textoCircular: "<p>Este es el texto de la circular<p>", no_leida: 0, leida: 0, favorita: 0, compartida: 0, eliminada: 0)
        
         //self.guardarCirculares(idCircular: 2, idUsuario: 1944, nombre: "TEST 2...", textoCircular: "<p>Este es el texto de la circular número 2<p>", no_leida: 0, leida: 0, favorita: 0, compartida: 0, eliminada: 0)
        
        
        setupLongPressGesture()
        
        
    }

    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 2.0 // 1 second press
        //longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableViewCirculares.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self.tableViewCirculares)
            if let indexPath = self.tableViewCirculares.indexPathForRow(at: touchPoint) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
                    as! CircularTableViewCell
                let c = circulares[indexPath.row]
                if cell.isSelected
                {
                    cell.isSelected = false
                    if cell.accessoryType == UITableViewCell.AccessoryType.none
                    {
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                        print(c.id)
                        
                    }
                    else
                    {
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                }
                
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if buscando{
           //  return circularesFiltradas.count
        //}else{
        return circulares.count
    //}
}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
            as! CircularTableViewCell
        let c = circulares[indexPath.row]
        //if buscando{
        //    let c = circularesFiltradas[indexPath.row]
        //}
        
        
        cell.lblEncabezado.text? = "Circular No. \(c.id)"
        cell.lblTitulo.text? = c.nombre.uppercased()
        var horaFecha = c.fecha.split{$0 == " "}.map(String.init)
        cell.lblFecha.text? = horaFecha[0]
        cell.lblHora.text? = horaFecha[1]
        cell.imgCircular.image = c.imagen
        
        /*let fuentePeq = UIFont(name: "Gotham Rounded", size: 12)
        let fuenteTitulo = UIFont(name: "Gotham Rounded", size: 14)
        cell.lblEncabezado.font = fuentePeq
        cell.lblTitulo.font = fuenteTitulo
        cell.lblFecha.font = fuentePeq*/
        /*if cell.isSelected
        {
            cell.isSelected = false
            if cell.accessoryType == UITableViewCell.AccessoryType.none
            {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            else
            {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }*/

        
        
        return cell
        
    }
    
    
    //Función para manejar el swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favAction = self.contextualFavAction(forRowAtIndexPath: indexPath)
        let eliminaAction = self.contextualDelAction(forRowAtIndexPath: indexPath)
        let noleerAction = self.contextualUnreadAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [eliminaAction,noleerAction,favAction])
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
    
    
    
    func contextualUnreadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
           // 1
           let circular = circulares[indexPath.row]
           // 2
           let action = UIContextualAction(style: .normal,
                                           title: "Compartida") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                                let idCircular:String = "\(circular.id)"
                                                                                         
                                            self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: idCircular)
                                                let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
                                               let _url = URL(string: address);
                                               self.obtenerCirculares(uri:address)
                                               
               
           }
           // 7
           action.image = UIImage(named: "unreadIcon")
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

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let c = circulares[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
            UserDefaults.standard.set(c.id,forKey:"id")
            UserDefaults.standard.set(c.nombre,forKey:"nombre")
            UserDefaults.standard.set(c.fecha,forKey:"fecha")
            UserDefaults.standard.set(c.contenido,forKey:"contenido")
            UserDefaults.standard.set(0, forKey: "viaNotif")
            performSegue(withIdentifier: "TcircularSegue", sender:self)
             
    }
    
    /*
     let crearTablaCirculares = "CREATE TABLE IF NOT EXISTS appCircular(idCircular INTEGER, idUsuario INTEGER, nombre TEXT, textoCircular TEXT, no_leida INTEGER, leida INTEGER, favorita INTEGER, compartida INTEGER, eliminada INTEGER)"
     */
    
    //Leer las circulares cuando no haya internet
    func leerCirculares(){
        
        let fileUrl = try!
                   FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
           let consulta = "SELECT * FROM appCircular WHERE idUsuario=\(self.idUsuario);"
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
                        
                        
                        if(Int(favorita)>0 && Int(leida) == 1){
                           imagen = UIImage.init(named: "appmenu06")!
                          }
                        var noLeida:Int = 0
                        if(Int(leida) == 0){
                            noLeida = 1
                            imagen = UIImage.init(named: "noleidas_celeste")!
                           }
                var fechaCircular="";
                if let fecha = sqlite3_column_text(queryStatement, 9) {
                    fechaCircular = String(cString: fecha).uppercased()
                   } else {
                    print("name not found")
                }
                
                self.circulares.append(CircularTodas(id:Int(id),imagen: imagen,encabezado: "",nombre: titulo,fecha: fechaCircular,estado: 0,contenido:cont))
              }
            
            self.tableViewCirculares.reloadData()

             }
            else {
             print("SELECT statement could not be prepared")
           }

           sqlite3_finalize(queryStatement)
       }
   
    
    //Esta función se utiliza para limpiar la base de datos cuando se abra al tener conexión a internet
    func limpiarCirculares(){
        let fileUrl = try!
                   FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
               
               if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
                   print("Error en la base de datos")
               }else{
                        var statement:OpaquePointer?
                let query = "DELETE FROM appCircular";
                if sqlite3_prepare(db,query,-1,&statement,nil) != SQLITE_OK {
                    print("Error")
                }
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Tabla borrada")
                }
                
                
        }
    }
    
    
    func guardarCirculares(idCircular:Int,idUsuario:Int,nombre:String, textoCircular:String,no_leida:Int, leida:Int,favorita:Int,compartida:Int,eliminada:Int,fecha:String){
        
        //Abrir la base
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
            print("Error en la base de datos")
        }else{
            //La base de datos abrió correctamente
            var statement:OpaquePointer?
            let query = "INSERT INTO appCircular(idCircular,idUsuario,nombre,textoCircular,no_leida,leida,favorita,compartida,eliminada,created_at) VALUES(?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare(db,query,-1,&statement,nil) != SQLITE_OK {
                print("Error")
            }
            
            if sqlite3_bind_int(statement,1,Int32(idCircular)) != SQLITE_OK {
                print("Error campo 1")
            }
            
            if sqlite3_bind_int(statement,2,Int32(idUsuario)) != SQLITE_OK {
                print("Error campo 2")
            }
            
            if sqlite3_bind_text(statement,3,nombre, -1, nil) != SQLITE_OK {
                print("Error campo 3")
            }
            
            if sqlite3_bind_text(statement,4,textoCircular, -1, nil) != SQLITE_OK {
                print("Error campo 4")
            }
            
            if sqlite3_bind_int(statement,5,Int32(no_leida)) != SQLITE_OK {
                print("Error campo 5")
            }
            
            if sqlite3_bind_int(statement,6,Int32(leida)) != SQLITE_OK {
                print("Error campo 6")
            }
            
            if sqlite3_bind_int(statement,7,Int32(favorita)) != SQLITE_OK {
                print("Error campo 7")
            }
            
            if sqlite3_bind_int(statement,8,Int32(compartida)) != SQLITE_OK {
                print("Error campo 8")
            }
            
            if sqlite3_bind_int(statement,9,Int32(eliminada)) != SQLITE_OK {
                print("Error campo 9")
            }
            
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Circular almacenada correctamente")
            }
            
        }
        
    
        
    }
    
    
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
                        
                        guard let fecha = diccionario["updated_at"] as? String else {
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
                        
                        //leídas
                        if(Int(leido)!>0){
                            imagen = UIImage.init(named: "leidas_azul")!
                        }
                        //No leídas
                        if(Int(leido)==0){
                            imagen = UIImage.init(named: "noleidas_celeste")!
                        }
                        if(Int(favorito)!>0){
                            imagen = UIImage.init(named: "appmenu06")!
                        }
                        var noLeida:Int = 0
                        if(Int(leido)! == 0){
                            noLeida = 1
                        }
                        
                        self.circulares.append(CircularTodas(id:Int(id)!,imagen: imagen,encabezado: "",nombre: titulo.uppercased(),fecha: fecha,estado: 0,contenido:""))
                        //Guardar las circulares
                        self.guardarCirculares(idCircular: Int(id)!, idUsuario: Int(self.idUsuario)!, nombre: titulo.uppercased(), textoCircular: texto, no_leida: noLeida, leida: Int(leido)!, favorita: Int(favorito)!, compartida: 0, eliminada: Int(eliminada)!,fecha: fecha)
                    }
                    
                    self.tableViewCirculares.reloadData()
                }
                
                
            
        
    }
        
    }
    

    //Operaciones con las circulares
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
    
    
    func noleerCircular(direccion:String, usuario_id:String, circular_id:String){
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
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            buscando=true
            circulares = circulares.filter({$0.nombre.contains(searchBar.text!.uppercased())})
            self.tableViewCirculares?.reloadData()
        }else{
            buscando=false
            view.endEditing(true)
            self.tableViewCirculares?.reloadData()
        }
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String) {
        if searchBar.text==nil || searchBar.text==""{
            buscando=false
            view.endEditing(true)
            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(self.idUsuario)"
            let _url = URL(string: address);
            self.obtenerCirculares(uri:address)
            
        }else{
            buscando=true
            circulares = circulares.filter({$0.nombre.contains(searchBar.text!.uppercased())})
            self.tableViewCirculares?.reloadData()
            
        }
    }
    
    
     

}
