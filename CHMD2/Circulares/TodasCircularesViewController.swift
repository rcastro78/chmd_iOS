//
//  TodasCircularesViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 4/10/20.
//  Copyright © 2020 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class TodasCircularesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UIGestureRecognizerDelegate,UITableViewDataSourcePrefetching {
func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetching row of \(indexPaths)")
    
    }
    
    @IBOutlet weak var btnDeshacer: UIBarButtonItem!
    
   @IBOutlet var tableViewCirculares: UITableView!
   @IBOutlet weak var barBusqueda: UISearchBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var btnMarcarFavoritas: UIButton!
    @IBOutlet weak var btnMarcarNoLeidas: UIButton!
    @IBOutlet weak var btnMarcarEliminadas: UIButton!
    @IBOutlet weak var btnMarcarLeidas: UIButton!
    
    
    
    @IBOutlet weak var btnEditar: UIBarButtonItem!
    
    var indexEliminar:Int=0
    var buscando=false
    var editando=false
    var circulares = [CircularTodas]()
    var circularesFiltradas = [CircularTodas]()
    var db: OpaquePointer?
    var idUsuario:String=""
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    var noleerMetodo:String="noleerCircular.php"
    var leerMetodo:String="leerCircular.php"
    var selecMultiple=false
    var circularesSeleccionadas = [Int]()
    var seleccion=[Int]()
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(_:true)
         circulares.removeAll()
         if ConexionRed.isConnectedToNetwork() == true {
         self.obtenerCirculares(limit:50)
         }else{
          
           
            self.leerCirculares()
        }
        //self.tableViewCirculares.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circulares.removeAll()
        self.hideKeyboardWhenTappedAround()
        self.tableViewCirculares.delegate=self
        self.tableViewCirculares.dataSource=self
        self.barBusqueda.delegate=self
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation=false
        }
        
        btnMarcarFavoritas.isHidden=true
        btnMarcarNoLeidas.isHidden=true
        btnMarcarLeidas.isHidden=true
        btnMarcarEliminadas.isHidden=true
        
        btnMarcarFavoritas.addTarget(self,action: #selector(agregarFavoritos), for: .touchUpInside)
        btnMarcarNoLeidas.addTarget(self,action: #selector(noleer), for: .touchUpInside)
         btnMarcarNoLeidas.addTarget(self,action: #selector(leer), for: .touchUpInside)
        btnMarcarEliminadas.addTarget(self,action: #selector(eliminar), for: .touchUpInside)
   
        
       
        tableViewCirculares.prefetchDataSource = self
        //self.title="Circulares"
        selecMultiple=false
        circularesSeleccionadas.removeAll()
        setupLongPressGesture()
       
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
        

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        self.tableViewCirculares.allowsMultipleSelection = true
        self.tableViewCirculares.allowsMultipleSelectionDuringEditing = true
        
     
        if ConexionRed.isConnectedToNetwork() == true {
            self.delete()
            //circulares.removeAll()
            //self.obtenerCirculares(limit:50)
             
             
        } else {
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Se muestran las últimas circulares registradas", delegate: nil, cancelButtonTitle: "Aceptar")
            alert.show()
            
            //print("Leer desde la base")
            self.leerCirculares()
            
        }
        
        
      
        
        
       
        
    }
    //Función para mantener los botones flotando
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        btnFavs.frame.origin.y = 300 + scrollView.contentOffset.y
        btnNoLeer.frame.origin.y = 380 + scrollView.contentOffset.y
        btnEliminar.frame.origin.y = 460 + scrollView.contentOffset.y
        btnDeshacer.frame.origin.y = 540 + scrollView.contentOffset.y
    }*/
    

   
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var valorInicial:Int=1
        var valorFinal:Int=5
        let ultimo = circulares.count - 1
        if indexPath.row == ultimo {
            //El método debe venir con top 15
            //del registro 1 al 15
            valorFinal = valorFinal+5
           self.obtenerCirculares(limit:valorFinal)
            print("se pasó el último registro")
            }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
   
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return circulares.count
    
}
    
    
   
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
            as! CircularTableViewCell
        let c = circulares[indexPath.row]
        //cell.lblEncabezado.text? = ""
        cell.lblTitulo.text? = c.nombre.uppercased()
        cell.chkSeleccionar.addTarget(self, action: #selector(seleccionMultiple), for: .touchUpInside)
       
       
        
         if(c.fecha != "")
         {
                          let dateFormatter = DateFormatter()
                          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                          dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                          let date1 = dateFormatter.date(from: c.fecha)
                          dateFormatter.dateFormat = "EEEE"
                          let dia = dateFormatter.string(from: date1!)
                  
                   
                   cell.lblFecha.text?=dia
         }
              
        cell.imgCircular.image = c.imagen
        
        if(!seleccion.contains(indexPath.row)){
              print("No seleccionada")
            cell.chkSeleccionar.isChecked=false
        }else{
            print("Seleccionada")
            cell.chkSeleccionar.isChecked=true
        }
        
        if(c.adjunto==1){
            cell.imgAdjunto.isHidden=false
        }
        if(c.adjunto==0){
            cell.imgAdjunto.isHidden=true
        }
       
       
        if(editando){
            let isEditing: Bool = self.isEditing
            cell.chkSeleccionar.isHidden = !isEditing
        }else{
            let isEditing: Bool = false
            cell.chkSeleccionar.isChecked=false
            cell.chkSeleccionar.isHidden = !isEditing
        }
       
        
        return cell
        
    }
    
    
    //Función para manejar el swipe
    //comentado RCASTRO 08/04/2020
    //Si tiene un menú a la izquierda el leadingSwipe no funciona
    //El leadingSwipe es para manejar el swipe de izquierda a derecha
    /*override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        let noleeAction = self.contextualUnreadAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [noleeAction])
        return swipeConfig
    }*/
    
    
    
    //El trailingSwipe es para manejar el swipe de derecha a izquierda
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let eliminaAction = self.contextualDelAction(forRowAtIndexPath: indexPath)
        let favAction = self.contextualFavAction(forRowAtIndexPath: indexPath)
        let leeAction = self.contextualReadAction(forRowAtIndexPath: indexPath)
        let noleeAction = self.contextualUnreadAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [eliminaAction,favAction,leeAction,noleeAction])
        return swipeConfig
    }
    
    func contextualReadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
           // 1
           let circular = circulares[indexPath.row]
           // 2
           let action = UIContextualAction(style: .normal,
                                           title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                                let idCircular:String = "\(circular.id)"
                                            if ConexionRed.isConnectedToNetwork() == true {
                                            self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: idCircular)
                                              self.circulares.remove(at: indexPath.row)
                                              self.tableViewCirculares.reloadData()
                                               }else{
                                                  var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                                                  alert.show()
                                     }
               
           }
           // 7
        action.image = UIImage(named: "read32")
        action.backgroundColor = UIColor.blue
           
           return action
       }
    
    
    func contextualFavAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
   
        let circular = circulares[indexPath.row]
        let action = UIContextualAction(style: .normal,
                                        title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let idCircular:String = "\(circular.id)"
                                            if ConexionRed.isConnectedToNetwork() == true {
                                            self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: idCircular)
                                                
                                                self.viewDidLoad()
                                                self.viewWillAppear(true)
                                                
                                                
                                            }else{
                                            var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                                            alert.show()
                                        }
                                            
                                            
            
        }
        // 7
        action.image = UIImage(named: "fav32")
        action.backgroundColor = UIColor.orange
        
        return action
    }
    
    
    
    func contextualUnreadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
           // 1
           let circular = circulares[indexPath.row]
           // 2
           let action = UIContextualAction(style: .normal,
                                           title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                                let idCircular:String = "\(circular.id)"
                                            if ConexionRed.isConnectedToNetwork() == true {
                                            self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: idCircular)
                                                self.viewDidLoad()
                                                self.viewWillAppear(true)
                                               }else{
                                                  var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                                                  alert.show()
                                     }
               
           }
           // 7
        action.image = UIImage(named: "unread32")
        action.backgroundColor = UIColor.blue
           
           return action
       }
    
    func contextualDelAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
      
        
        let circular = circulares[indexPath.row]
        // 2
        let action = UIContextualAction(style: .normal,
                                        title: "") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let idCircular:String = "\(circular.id)"
                                            if ConexionRed.isConnectedToNetwork() == true {
                                            self.delCircular(direccion: self.urlBase+"eliminarCircular.php", usuario_id: self.idUsuario, circular_id: idCircular)
                                            //self.obtenerCirculares(limit:15)
                                                self.indexEliminar=indexPath.row
                                        
                                            }else{
                                                var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                                                 alert.show()
                                            }
                                            
            
        }
        // 7
        action.image = UIImage(named: "delIcon32")
        action.backgroundColor = UIColor.red
        
        return action
    }

    

    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if(!editando){
            
            
            /*
             guard let fecha = diccionario["updated_at"] as? String else {
                 print("No se pudo obtener la fecha")
                 return
             }
             */
            
        let c = circulares[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
            UserDefaults.standard.set(indexPath.row,forKey:"posicion")
            UserDefaults.standard.set(c.id,forKey:"id")
            UserDefaults.standard.set(c.nombre,forKey:"nombre")
            UserDefaults.standard.set(c.fecha,forKey:"fecha")
            UserDefaults.standard.set(c.contenido,forKey:"contenido")
            UserDefaults.standard.set(c.fechaIcs,forKey:"fechaIcs")
            UserDefaults.standard.set(c.horaInicialIcs,forKey:"horaInicialIcs")
            UserDefaults.standard.set(c.horaFinalIcs,forKey:"horaFinalIcs")
            UserDefaults.standard.set(c.nivel,forKey:"nivel")
            UserDefaults.standard.set(0, forKey: "viaNotif")
            performSegue(withIdentifier: "TcircularSegue", sender:self)
        }else{
         
        }
        
        
        
             
    }
    
  
    
    //Leer las circulares cuando no haya internet
    func leerCirculares(){
        
        let fileUrl = try!
                   FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
           let consulta = "SELECT * FROM appCirculares"
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
                
                       if let contenido = sqlite3_column_text(queryStatement,3) {
                           cont = String(cString: contenido)
                          } else {
                           print("name not found")
                       }
              
                        let leida = sqlite3_column_int(queryStatement, 5)
                        let favorita = sqlite3_column_int(queryStatement, 6)
                        let eliminada = sqlite3_column_int(queryStatement, 8)
                        
                
                                        var fechaIcs:String="";
                                        if let fIcs = sqlite3_column_text(queryStatement, 10) {
                                          fechaIcs = String(cString: fIcs)
                                         } else {
                                          print("name not found")
                                      }
                
                               
                                    
                
                       
                  var hIniIcs:String="";
                  if  let horaInicioIcs = sqlite3_column_text(queryStatement, 11) {
                    hIniIcs = String(cString: horaInicioIcs)
                   } else {
                    print("name not found")
                }
                        
                
                 var hFinIcs:String="";
                 if  let horaFinIcs = sqlite3_column_text(queryStatement, 12) {
                     hFinIcs = String(cString: horaFinIcs)
                     } else {
                       print("name not found")
                     }
                
                
                
                        
                        
                
                var nivel:String="";
                if  let nv = sqlite3_column_text(queryStatement, 12) {
                    nivel = String(cString: nv)
                    } else {
                      print("name not found")
                    }
                
                        let adj = sqlite3_column_int(queryStatement, 13)
                        if(Int(leida)>0){
                           imagen = UIImage.init(named: "circle_white")!
                         }
                        
                        if(Int(leida) == 1){
                    
                        }
                
                        if(Int(favorita)==1){
                           imagen = UIImage.init(named: "star")!
                          }
                        var noLeida:Int = 0
                        if(Int(leida) == 0){
                            noLeida = 1
                            imagen = UIImage.init(named: "circle")!
                           }
                var fechaCircular="";
                if let fecha = sqlite3_column_text(queryStatement, 8) {
                    fechaCircular = String(cString: fecha)
                    print("fecha c: \(fechaCircular)")
                   } else {
                    print("name not found")
                }
                
                
        
                self.circulares.append(CircularTodas(id:Int(id),imagen: imagen,encabezado: "",nombre: titulo.uppercased(),fecha: fechaCircular,estado: 0,contenido:cont.replacingOccurrences(of: "&#92", with: ""),adjunto:Int(adj),fechaIcs:fechaIcs,horaInicialIcs: hIniIcs,horaFinalIcs: hFinIcs, nivel:nivel))
              }
            
            self.tableViewCirculares.reloadData()

             }
            else {
             print("SELECT statement could not be prepared")
           }

           sqlite3_finalize(queryStatement)
       }
   
    
    //Esta función se utiliza para limpiar
    //la base de datos cuando se abra al tener conexión a internet
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
    
    func borrarCirculares(){
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
            print("Error en la base de datos")
        }else{
        let q = "DELETE FROM appCirculares"
            var statement:OpaquePointer?
        if sqlite3_prepare(db,q,-1,&statement,nil) != SQLITE_OK {
            print("Error")
        }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                           print("Tabla borrada correctamente")
                       }else{
                           print("No se pudo borrar")
                       }
        
        }
        
    }
    
    
    func delete() {
        
        let fileUrl = try!
                   FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
               
               if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
                   print("Error en la base de datos")
               }else{
        
      var deleteStatement: OpaquePointer?
        var deleteStatementString="DELETE FROM appCirculares"
      if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
          print("BASE:Successfully deleted row.")
        } else {
          print("BASE:Could not delete row.")
        }
      } else {
        print("BASE:DELETE statement could not be prepared")
      }
      
      sqlite3_finalize(deleteStatement)
        }
    
    }
    
    
    
    func guardarCirculares(idCircular:Int,idUsuario:Int,nombre:String, textoCircular:String,no_leida:Int, leida:Int,favorita:Int,compartida:Int,eliminada:Int,fecha:String,fechaIcs:String,horaInicioIcs:String,horaFinIcs:String,nivel:String,adjunto:Int){
        
        //Abrir la base
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
            print("Error en la base de datos")
        }else{
            
           
            
            
            
            //La base de datos abrió correctamente
            var statement:OpaquePointer?
            
             //Vaciar la tabla
            
            
            let query = "INSERT INTO appCirculares(idCircular,idUsuario,nombre,textoCircular,no_leida,leida,favorita,compartida,eliminada,created_at,fechaIcs,horaInicioIcs,horaFinIcs,nivel,adjunto) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
            if sqlite3_prepare(db,query,-1,&statement,nil) != SQLITE_OK {
                print("Error")
            }
            
            if sqlite3_bind_int(statement,1,Int32(idCircular)) != SQLITE_OK {
                print("Error campo 1")
            }
            
            if sqlite3_bind_int(statement,2,Int32(idUsuario)) != SQLITE_OK {
                print("Error campo 2")
            }
            let n = nombre as NSString
            if sqlite3_bind_text(statement,3,n.utf8String, -1, nil) != SQLITE_OK {
                print("Error campo 3")
            }
            let texto = textoCircular as NSString
            if sqlite3_bind_text(statement,4,texto.utf8String, -1, nil) != SQLITE_OK {
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
            
            if sqlite3_bind_int(statement,8,Int32(eliminada)) != SQLITE_OK {
                           print("Error campo 7")
                       }
            
           if sqlite3_bind_text(statement,9,fecha, -1, nil) != SQLITE_OK {
               print("Error campo 3")
           }
            
            if sqlite3_bind_text(statement,10,fechaIcs, -1, nil) != SQLITE_OK {
                print("Error campo 3")
            }
            if sqlite3_bind_text(statement,11,horaInicioIcs, -1, nil) != SQLITE_OK {
                           print("Error campo 3")
            }
            if sqlite3_bind_text(statement,12,horaFinIcs, -1, nil) != SQLITE_OK {
                           print("Error campo 3")
            }
            if sqlite3_bind_text(statement,13,nivel, -1, nil) != SQLITE_OK {
                           print("Error campo 3")
            }
            
            if sqlite3_bind_int(statement,14,Int32(adjunto)) != SQLITE_OK {
                print("Error campo 7")
            }
            
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Circular almacenada correctamente")
            }else{
                print("Circular no se pudo guardar")
            }
            
        }
        
    
        
    }
    
    
    func obtenerCirculares(limit:Int){
        self.circulares.removeAll()
        
        let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarioLazyLoad.php?usuario_id=\(self.idUsuario)&limit=\(limit)"
       
        
        Alamofire.request(address)
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
                        
                        
                        
                        var imagen:UIImage
                        imagen = UIImage.init(named: "appmenu05")!
                        
                        
                        guard let leido = diccionario["leido"] as? String else {
                            return
                        }
                        
                        guard let fecha = diccionario["created_at"] as? String else {
                                                   return
                                               }
                        
                        guard let favorito = diccionario["favorito"] as? String else {
                            return
                        }
                        
                        guard let adjunto = diccionario["adjunto"] as? String else {
                                                   return
                                               }
                        
                        guard let eliminada = diccionario["eliminado"] as? String else {
                            return
                        }
                        
                        guard let texto = diccionario["contenido"] as? String else {
                            return
                        }
                        
                        guard let fechaIcs = diccionario["fecha_ics"] as? String else {
                          return
                        }
                        guard let horaInicioIcs = diccionario["hora_inicial_ics"] as? String else {
                                                 return
                                               }
                        
                       
                        guard let horaFinIcs = diccionario["hora_final_ics"] as? String else {
                                                                        return
                                                                      }
                        
                     
                        //Con esto se evita la excepcion por los valores nulos
                        var nv:String?
                        if (diccionario["nivel"] == nil){
                            nv=""
                        }else{
                            nv=diccionario["nivel"] as? String
                        }

                        
                       
                        
                        //leídas
                        if(Int(leido)!>0){
                            imagen = UIImage.init(named: "circle_white")!
                        }
                        //No leídas
                        if(Int(leido)==0 && Int(favorito)==0){
                            imagen = UIImage.init(named: "circle")!
                        }
                        
                        var noLeida:Int = 0
                        if(Int(leido)! == 0){
                            noLeida = 1
                        }
                        
                        var adj=0;
                        if(Int(adjunto)!==1){
                            adj=1
                        }
                       
                        if(Int(favorito)!>0){
                            imagen = UIImage.init(named: "star")!
                        }
                        
                        var str = texto.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
                        .replacingOccurrences(of: "&amp;aacute;", with: "á")
                        .replacingOccurrences(of: "&amp;eacute;", with: "é")
                        .replacingOccurrences(of: "&amp;iacute;", with: "í")
                        .replacingOccurrences(of: "&amp;oacute;", with: "ó")
                        .replacingOccurrences(of: "&amp;uacute;", with: "ú")
                        .replacingOccurrences(of: "&amp;ordm;", with: "o.")
                        print("Contenido: "+str)
                        if(Int(eliminada)!==0){
                             self.circulares.append(CircularTodas(id:Int(id)!,imagen: imagen,encabezado: "",nombre: titulo.uppercased(),fecha: fecha,estado: 0,contenido:"",adjunto:adj,fechaIcs: fechaIcs,horaInicialIcs: horaInicioIcs,horaFinalIcs: horaFinIcs, nivel:nv ?? ""))
                        }
                        
                      
                        //Guardar las circulares
                        
                        
                        
                        self.guardarCirculares(idCircular: Int(id)!, idUsuario: Int(self.idUsuario)!, nombre: titulo.uppercased(), textoCircular: str, no_leida: noLeida, leida: Int(leido)!, favorita: Int(favorito)!, compartida: 0, eliminada: Int(eliminada)!,fecha: fecha,fechaIcs: fechaIcs,horaInicioIcs: horaInicioIcs,horaFinIcs: horaFinIcs,nivel: nv ?? "",adjunto:adj)
                    }
                    
                     
                    
                }
             
        self.tableViewCirculares.reloadData()
    }
        
        
        
    }
    
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableViewCirculares.addGestureRecognizer(longPressGesture)
        
        //Mostrar los botones
              
        
    }
    
    
    
    /*let footerView = UIView()
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView.isHidden=true
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:
       100)
     
                                //Favoritos al pie
                                let btnFavoritos = UIButton(type: .custom)
                                 btnFavoritos.frame=CGRect(x:10,y:20,width:32,height:32)
                                 btnFavoritos.setImage(UIImage(named:"estrella_fav"), for: .normal)
                                 //btnFavoritos.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                                 btnFavoritos.clipsToBounds = true
                                 //btnFavoritos.layer.cornerRadius = 32
                                 //btnFavoritos.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                               
                                 btnFavoritos.addTarget(self,action: #selector(agregarFavoritos), for: .touchUpInside)
        
        
        let btnNoLeidos = UIButton(type: .custom)
        btnNoLeidos.frame=CGRect(x:100,y:20,width:32,height:32)
        btnNoLeidos.setImage(UIImage(named:"icono_noleido"), for: .normal)
        //btnNoLeidos.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        btnNoLeidos.clipsToBounds = true
        //btnNoLeidos.layer.cornerRadius = 32
        //btnNoLeidos.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        btnNoLeidos.addTarget(self,action: #selector(noleer), for: .touchUpInside)
        
        
              let btnEliminar = UIButton(type: .custom)
               btnEliminar.frame=CGRect(x:180,y:20,width:32,height:32)
               btnEliminar.setImage(UIImage(named:"delIcon"), for: .normal)
               //btnEliminar.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
               btnEliminar.clipsToBounds = true
               //btnEliminar.layer.cornerRadius = 32
               //btnEliminar.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
              
               btnEliminar.addTarget(self,action: #selector(eliminar), for: .touchUpInside)
        
        
        let btnDeshacer = UIButton(type: .custom)
        btnDeshacer.frame=CGRect(x:260,y:20,width:32,height:32)
        btnDeshacer.setImage(UIImage(named:"undo"), for: .normal)
        //btnDeshacer.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        btnDeshacer.clipsToBounds = true
        //btnDeshacer.layer.cornerRadius = 32
        //btnDeshacer.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
       
        btnDeshacer.addTarget(self,action: #selector(deshacer), for: .touchUpInside)
        
        
       footerView.addSubview(btnFavoritos)
       footerView.addSubview(btnNoLeidos)
       footerView.addSubview(btnEliminar)
       footerView.addSubview(btnDeshacer)
       return footerView
    }
    */
    //el pie
     @objc func seleccionMultiple(_ sender:UIButton){
        var superView = sender.superview
        
        while !(superView is UITableViewCell) {
            superView = superView?.superview
        }
        let cell = superView as! CircularTableViewCell
        if let indexpath = tableViewCirculares.indexPath(for: cell){
            if(cell.chkSeleccionar.isChecked){
                //footerView.isHidden=false;
                //let c = tableViewCirculares.cellForRow(at: indexpath) as! CircularTableViewCell
                btnMarcarFavoritas.isHidden=false
                btnMarcarNoLeidas.isHidden=false
                btnMarcarLeidas.isHidden=false
                btnMarcarEliminadas.isHidden=false
                
                /*btnFavs.isHidden=false
                btnNoLeer.isHidden=false
                btnEliminar.isHidden=false
                btnDeshacer.isHidden=false*/
                tableViewCirculares.allowsSelection = true
                let c = circulares[indexpath.row]
                //print("Seleccionado: \(c.id)")
                circularesSeleccionadas.append(c.id)
                seleccion.append(indexpath.row)
                print("recuento: \(circularesSeleccionadas.count)")
            }else{
               let c = circulares[indexpath.row]
                //print("No Seleccionado: \(c.id)")
                let itemEliminar = c.id
                let selecEliminar = indexpath.row
                while circularesSeleccionadas.contains(itemEliminar) {
                    if let indice = circularesSeleccionadas.firstIndex(of: itemEliminar) {
                        let index = seleccion.firstIndex(of: selecEliminar) ?? 0
                        circularesSeleccionadas.remove(at: indice)
                        seleccion.remove(at: index)
                    }
                }
                
                if(circularesSeleccionadas.count<=0){
                      /*btnFavs.isHidden=true
                      btnNoLeer.isHidden=true
                      btnEliminar.isHidden=true
                      btnDeshacer.isHidden=true*/
                    btnMarcarFavoritas.isHidden=true
                    btnMarcarNoLeidas.isHidden=true
                    btnMarcarLeidas.isHidden=true
                    btnMarcarEliminadas.isHidden=true
                    tableViewCirculares.allowsSelection = false
                }
                         
              
                
                //print("recuento: \(circularesSeleccionadas.count)")
            }
        }
    }
    
    
    @objc func agregarFavoritos(){
        
        
          if ConexionRed.isConnectedToNetwork() == true {
          for c in circularesSeleccionadas{
            print("circular: \(c)")
          self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: "\(c)")
          
          }
            
            seleccion.removeAll()
            circularesSeleccionadas.removeAll()
           
           self.viewDidLoad()
           self.viewWillAppear(true)
            
            self.obtenerCirculares(limit:50)
            tableViewCirculares.reloadData()
            
          }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
             alert.show()
        }
        
    }
    @objc func leer(){
        
        
          if ConexionRed.isConnectedToNetwork() == true {
          for c in circularesSeleccionadas{
            print("circular: \(c)")
            self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: "\(c)")
          
          }
            
            seleccion.removeAll()
            circularesSeleccionadas.removeAll()
           
           self.viewDidLoad()
           self.viewWillAppear(true)
            
            self.obtenerCirculares(limit:50)
            tableViewCirculares.reloadData()
            
          }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
             alert.show()
        }
        
    }
    
    @objc func eliminar(){
     if ConexionRed.isConnectedToNetwork() == true {
        
        
         
                                self.circulares.removeAll()
                                for c in self.circularesSeleccionadas{
                                      self.delCircularTodas(direccion: self.urlBase+"eliminarCircular.php", usuario_id: self.idUsuario, circular_id: "\(c)")
                                }
                                
                                self.seleccion.removeAll()
                                self.circularesSeleccionadas.removeAll()
                                        
                                        self.viewDidLoad()
                                        self.viewWillAppear(true)
                                         
                                         self.obtenerCirculares(limit:50)
                                self.tableViewCirculares.reloadData()
                            /*})
                            
                            // Create Cancel button with action handlder
                            let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                                
                            }
                            
                            //Add OK and Cancel button to dialog message
                            dialogMessage.addAction(ok)
                            dialogMessage.addAction(cancel)
                            
                            // Present dialog message to user
                            self.present(dialogMessage, animated: true, completion: nil)*/
            
            
            
        
        
        
       } else{
                  var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                   alert.show()
        }
        
    }
    
    @objc func deshacer(){
    
    }
    
    @objc func noleer(){
        if ConexionRed.isConnectedToNetwork() == true {
        circulares.removeAll()
           for c in circularesSeleccionadas{
           self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: "\(c)")
        }
      
             seleccion.removeAll()
             circularesSeleccionadas.removeAll()
                     
                     self.viewDidLoad()
                     self.viewWillAppear(true)
                      
                      self.obtenerCirculares(limit:50)
                      tableViewCirculares.reloadData()
           
            
       }else{
                       var alert = UIAlertView(title: "No está conectado a Internet", message: "Para ejecutar esta acción debes tener una conexión activa a la red", delegate: nil, cancelButtonTitle: "Aceptar")
                        alert.show()
             }
       }

    //Pie
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            //footerView.isHidden=false
            //footerView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
           
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
    
    
    func delCircularTodas(direccion:String, usuario_id:String, circular_id:String){
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
     
    //Preguntar
    let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
               
               // Create OK button with action handler
               let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                
                
                let parameters: Parameters = ["usuario_id": usuario_id, "circular_id": circular_id]      //This will be your parameter
                    Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
                        switch (response.result) {
                        case .success:
                            print(response)
                            self.circulares.remove(at: self.indexEliminar)
                            self.tableViewCirculares.reloadData()
                            break
                        case .failure:
                            print(Error.self)
                        }
                    }
                
                
                
                })
    
    
    let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                   
               }
               
               //Add OK and Cancel button to dialog message
               dialogMessage.addAction(ok)
               dialogMessage.addAction(cancel)
               
               // Present dialog message to user
               self.present(dialogMessage, animated: true, completion: nil)
    
 }
    
    
    
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            buscando=true
            print("Buscar")
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
            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuariosLazyLoad.php?usuario_id=\(self.idUsuario)&limit=15"
            let _url = URL(string: address);
            self.obtenerCirculares(limit:15)
            
        }else{
            buscando=true
             print("Buscar")
            circulares = circulares.filter({$0.nombre.contains(searchBar.text!.uppercased())})
            self.tableViewCirculares?.reloadData()
            
        }
    }
    
    
    
    @IBAction func unwindCirculares(segue:UIStoryboardSegue) {}
     

    
    
    @IBAction func habilitarSeleccion(_ sender: Any) {
        if(!editando){
            self.isEditing=true
            editando=true
            tableViewCirculares.reloadData()
            self.btnEditar.title="Cancelar"
            
        }else{
            self.isEditing=false
            editando=false
            tableViewCirculares.reloadData()
            seleccion.removeAll()
            self.btnEditar.title="Editar"
            btnMarcarFavoritas.isHidden=true
            btnMarcarLeidas.isHidden=true
            btnMarcarNoLeidas.isHidden=true
            btnMarcarEliminadas.isHidden=true
        }
        
    }
    
    
}
