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

class CircularTableViewController: UITableViewController {
    @IBOutlet var tableViewCirculares: UITableView!
    var circulares = [CircularTodas]()
    var db: OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
        circulares.removeAll()
        let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCirculares.php?usuario_id=5"
        let _url = URL(string: address);
        obtenerCirculares(uri:address)
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
                
                if cell.isSelected
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
        // #warning Incomplete implementation, return the number of rows
        return circulares.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
            as! CircularTableViewCell
        let c = circulares[indexPath.row]
        
        
        
        
        cell.lblEncabezado.text? = "Circular No. \(c.id)"
        cell.lblTitulo.text? = c.nombre
        cell.lblFecha.text? = c.fecha
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let c = circulares[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
            UserDefaults.standard.set(c.id,forKey:"id")
            UserDefaults.standard.set(c.nombre,forKey:"nombre")
            performSegue(withIdentifier: "TcircularSegue", sender:self)
             
    }
    
    /*
     let crearTablaCirculares = "CREATE TABLE IF NOT EXISTS appCircular(idCircular INTEGER, idUsuario INTEGER, nombre TEXT, textoCircular TEXT, no_leida INTEGER, leida INTEGER, favorita INTEGER, compartida INTEGER, eliminada INTEGER)"
     */
    
    func guardarCirculares(idCircular:Int,idUsuario:Int,nombre:String, textoCircular:String,no_leida:Int, leida:Int,favorita:Int,compartida:Int,eliminada:Int){
        
        //Abrir la base
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
            print("Error en la base de datos")
        }else{
            //La base de datos abrió correctamente
            var statement:OpaquePointer?
            let query = "INSERT INTO appCircular(idCircular,idUsuario,nombre,textoCircular,no_leida,leida,favorita,compartida,eliminada) VALUES(?,?,?,?,?,?,?,?,?)"
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
                        print(diccionario)//print each of the dictionaries
                        
                        guard let id = diccionario["id"] as? String else {
                            print("No se pudo obtener el id")
                            return
                        }
                        
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
                        
                        guard let compartida = diccionario["compartida"] as? String else {
                            return
                        }
                        guard let eliminada = diccionario["eliminado"] as? String else {
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
                        
                        if(Int(compartida)!>0){
                            imagen = UIImage.init(named: "appmenu08")!
                        }
                        
                       
                        var noLeida:Int = 0
                        if(Int(leido)! == 0){
                            noLeida = 1
                        }
                        
                         self.circulares.append(CircularTodas(id:Int(id)!,imagen: imagen,encabezado: "",nombre: titulo,fecha: fecha,estado: 0))
                        //Guardar las circulares
                        /*self.guardarCirculares(idCircular: Int(id)!, idUsuario: 1660, nombre: titulo, textoCircular: "", no_leida: noLeida, leida: Int(leido)!, favorita: Int(favorito)!, compartida: Int(compartida)!, eliminada: Int(eliminada)!)*/
                    }
                    
                    self.tableViewCirculares.reloadData()
                }
                
                
            
        
    }
        
    }
    

 

}
