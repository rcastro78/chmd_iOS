//
//  CircularDetalleViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/26/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import EventKit

//import BitlySDK
class CircularDetalleViewController: UIViewController {

    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblFechaCircular: UILabel!
    
    var ids = [String]()
    var titulos = [String]()
    var idInicial:Int=0
    var posicion:Int=0
    var id:String=""
    var idUsuario=""
    var favMetodo:String="favCircular.php"
    var delMetodo:String="eliminarCircular.php"
    var noleerMetodo:String="noleerCircular.php"
    var leerMetodo:String="leerCircular.php"
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    var circularUrl:String=""
    var circularTitulo:String=""

    override func viewDidLoad() {
        super.viewDidLoad()
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
        let titulo = UserDefaults.standard.string(forKey: "nombre") ?? ""
        circularTitulo = titulo
        let fecha = UserDefaults.standard.string(forKey: "fecha") ?? ""
        let contenido = UserDefaults.standard.string(forKey:"contenido") ?? ""
        id = UserDefaults.standard.string(forKey: "id") ?? ""
        idInicial = Int(UserDefaults.standard.string(forKey: "id") ?? "0")!
        
        let anio = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
        let mes = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
        let dia = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
        lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
        
        self.title = titulo.uppercased()
        
        if(ConexionRed.isConnectedToNetwork()){
            let link = URL(string:urlBase+"getCircularId2.php?id=\(id)")!
                  let request = URLRequest(url: link)
                  webView.load(request)
                  
                  let address=urlBase+"getCircularesUsuarios.php?usuario_id=\(idUsuario)"
                  circularUrl = address
                  if ConexionRed.isConnectedToNetwork() == true {
                             let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarios.php?usuario_id=\(idUsuario)"
                               let _url = URL(string: address);
                             self.obtenerCirculares(uri:address)
                             
                         }
                  
                  //obtener la primer posicion
                  posicion = find(value: id,in: ids) ?? 0
                  
                  //Marcar la circular como leída
                  self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
        }else{
            webView.loadHTMLString("<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header><body><p><h3>\(contenido)</h3></p></body></html>", baseURL: nil)
        }
        
      
        
        
    }
    
    
    func find(value searchValue: String, in array: [String]) -> Int?
    {
        for (index, value) in array.enumerated()
        {
            if value == searchValue {
                return index
            }
        }
        
        return nil
    }
    
    
    func insertarEvento(store: EKEventStore,titulo:String,fechaIcs:String,horaInicioIcs:String,horaFinIcs:String,ubicacionIcs:String) {
        let calendario = store.calendars(for: .event)
        
        //Convertir las horas
        let dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
      
        let calendar = calendario[0]
        let startDate = dateFormatter.date(from: "2019-01-21T09:00")
        let eDate = dateFormatter.date(from: "2019-01-21T11:00")
        print(startDate)
        print(eDate)
        let endDate = eDate
        let event = EKEvent(eventStore: store)
        event.calendar = calendar
        event.title = titulo.uppercased()
        event.startDate = startDate
        event.endDate = eDate

        do {
            try store.save(event, span: .thisEvent)
        }
        catch {
           print("Error guardando el evento")
            
            }
        
        
    }
        
    @IBAction func btnCalendarioClick(_ sender: UIButton) {
         let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertarEvento(store: eventStore,titulo: circularTitulo,fechaIcs: "2019-01-21",horaInicioIcs: "09:00",horaFinIcs: "12:00",ubicacionIcs: "En el colegio")
            case .denied:
                print("Acceso denegado")
            case .notDetermined:
            // 3
                eventStore.requestAccess(to: .event, completion:
                  {[weak self] (granted: Bool, error: Error?) -> Void in
                      if granted {
                        self!.insertarEvento(store: eventStore,titulo: self?.circularTitulo ?? "",
                                             fechaIcs: "2019-01-21",horaInicioIcs: "09:00",horaFinIcs: "12:00",ubicacionIcs: "En el colegio")
                      } else {
                            print("Acceso denegado")
                      }
                })
                default:
                    print("Case default")
        }
        
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
       //obtener la posición del elemento cargado
        posicion = posicion+1
        
        print(ids.count)
        
        if(posicion<ids.count){
            var nextId = ids[posicion]
            var nextTitulo = titulos[posicion]
            circularTitulo = nextTitulo
            let link = URL(string:urlBase+"getCircularId2.php?id=\(nextId)")!
            let request = URLRequest(url: link)
            circularUrl = urlBase+"getCircularId2.php?id=\(nextId)"
            webView.load(request)
            self.title = nextTitulo.uppercased()
            id = nextId;
        }else{
            posicion = 0
            id = UserDefaults.standard.string(forKey: "id") ?? ""
        }
        
    }
        
        
        
        
    
    
    
    @IBAction func btnAntClick(_ sender: UIButton) {
        posicion = posicion-1
        if(posicion>=0){
            var nextId = ids[posicion]
            var nextTitulo = titulos[posicion]
             circularTitulo = nextTitulo
            let link = URL(string:urlBase+"getCircularId2.php?id=\(nextId)")!
            circularUrl = urlBase+"getCircularId2.php?id=\(nextId)"
            let request = URLRequest(url: link)
            webView.load(request)
            self.title = nextTitulo.uppercased()
            id = nextId
        }else{
            posicion = ids.count
        }
        
    }
    
    //419 33 166
    //383 33 231
    @IBAction func btnFavClick(_ sender: UIButton) {
        //Hacer favorita la circular
        
        if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar esta circular a tus favoritas?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: self.id)
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                       alert.show()
        }
        
        
        
        
    }
    
    @IBAction func btnCompartirClick(_ sender: UIButton) {
        var link:String=""
        //Crear el link mediante bit.ly, para pruebas
        circularUrl = "https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularId2?id=\(id)"
        /*Bitly.shorten(circularUrl) { response, error in
            link = response?.bitlink ?? ""
        }*/
        
        compartir(message: "Compartiendo", link: link)
    }
    
    
    func compartir(message: String, link: String) {
        if let link = URL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func btnNoLeerClick(_ sender: Any) {
        
         if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas marcar esta circular como no leída?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
         }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                                  alert.show()
        }

        
        
    }
    
    
    @IBAction func btnEliminarClick(_ sender: UIButton) {
        
        if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.delCircular(direccion: self.urlBase+self.delMetodo, usuario_id:self.idUsuario, circular_id: self.id)
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                                             alert.show()
        }
        
        
    }
    
    
    //Esta función es para ejecutar una petición POST
    func shareCircular(direccion:String){
        let url = URL(string: direccion)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                }
            }
        }
        task.resume()
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
    
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
                      self.ids.append(id)
                      self.titulos.append(titulo)
                }
                
                
            
        
    }
        
 }
    
    
    
}
    
  
    
}

    


