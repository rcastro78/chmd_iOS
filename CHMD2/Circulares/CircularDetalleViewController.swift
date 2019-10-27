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
class CircularDetalleViewController: UIViewController {

    
    @IBOutlet weak var webView: WKWebView!
    var ids = [String]()
    var titulos = [String]()
    var idInicial:Int=0
    var posicion:Int=0
    var id:String=""
    var favMetodo:String="favCircular.php"
    var delMetodo:String="eliminarCircular.php"
    var noleerMetodo:String="noleerCircular.php"
    var leerMetodo:String="leerCircular.php"
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    override func viewDidLoad() {
        super.viewDidLoad()
        let titulo = UserDefaults.standard.string(forKey: "nombre") ?? ""
        id = UserDefaults.standard.string(forKey: "id") ?? ""
        idInicial = Int(UserDefaults.standard.string(forKey: "id") ?? "0")!
        //lblTitulo.text = titulo
        self.title = titulo
        let link = URL(string:urlBase+"getCircularId2.php?id=\(id)")!
        let request = URLRequest(url: link)
        webView.load(request)
        
        let address=urlBase+"getCirculares.php?usuario_id=5"
        let _url = URL(string: address);
        getDataFromURL(url: _url!)
        
        //obtener la primer posicion
        posicion = find(value: id,in: ids) ?? 0
        
        //Marcar la circular como leída
        self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: "1660", circular_id: self.id)
        
        
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
    
    
    
    @IBAction func btnNextClick(_ sender: UIButton) {
       //obtener la posición del elemento cargado
        posicion = posicion+1
        if(posicion<ids.count){
            var nextId = ids[posicion]
            var nextTitulo = titulos[posicion]
            let link = URL(string:"https://www.chmd.edu.mx/pruebascd/app/webservices/getCircularId2.php?id=\(nextId)")!
            let request = URLRequest(url: link)
            webView.load(request)
            self.title = nextTitulo
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
            let link = URL(string:"https://www.chmd.edu.mx/pruebascd/app/webservices/getCircularId2.php?id=\(nextId)")!
            let request = URLRequest(url: link)
            webView.load(request)
            self.title = nextTitulo
            id = nextId
        }else{
            posicion = ids.count
        }
        
    }
    
    
    @IBAction func btnFavClick(_ sender: UIButton) {
        //Hacer favorita la circular
        let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar esta circular a tus favoritas?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
            self.favCircular(direccion: "https://www.chmd.edu.mx/pruebascd/app/webservices/favCircular.php", usuario_id: "1660", circular_id: self.id)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
            
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
        
    }
    
    @IBAction func btnCompartirClick(_ sender: UIButton) {
    }
    
    
    
    @IBAction func btnNoLeerClick(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas marcar esta circular como no leída?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
            self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: "1660", circular_id: self.id)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
            
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    @IBAction func btnEliminarClick(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
            self.delCircular(direccion: self.urlBase+self.delMetodo, usuario_id: "1660", circular_id: self.id)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
            
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
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
    
    
    func getDataFromURL(url: URL) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let datos = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]] {
                if(!datos.isEmpty){
                    for index in 0...((datos).count) - 1
                    {
                        let obj = datos[index] as! [String : AnyObject]
                        let id = obj["id"] as! String
                        let titulo = obj["titulo"] as! String
                        self.ids.append(id)
                        self.titulos.append(titulo)
                        
                    }
                    
                }
                OperationQueue.main.addOperation {
                    
                }
            }
            
            }.resume()
        
    }
    
}

    


