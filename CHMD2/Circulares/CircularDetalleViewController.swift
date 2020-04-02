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
import Firebase
import BitlySDK
import MarqueeLabel




class CircularDetalleViewController: UIViewController {

    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lblFechaCircular: UILabel!
    @IBOutlet weak var lblTituloParte1: MarqueeLabel!
    @IBOutlet weak var lblTituloParte2: UILabel!
    @IBOutlet weak var lblTituloNivel: UILabel!
    @IBOutlet weak var imbCalendario: UIButton!
   
    @IBOutlet weak var lblContenidoHTML: UITextView!
    @IBOutlet weak var lblNivel: UILabel!
    var ids = [String]()
    var titulos = [String]()
    var fechas = [String]()
    var niveles = [String]()
    var fechasIcs = [String]()
    var horasInicioIcs = [String]()
    var horasFinIcs = [String]()
    var idInicial:Int=0
    var posicion:Int=0
    var viaNotif:Int=0
    var id:String=""
    var idUsuario=""
    var horaInicialIcs=""
    var horaFinalIcs=""
    var fechaIcs=""
    var nivel=""
    var favMetodo:String="favCircular.php"
    var delMetodo:String="eliminarCircular.php"
    var noleerMetodo:String="noleerCircular.php"
    var leerMetodo:String="leerCircular.php"
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    var circularUrl:String=""
    var circularTitulo:String=""
    var metodo_circular="getCircularId.php"
    var contenido:String=""
    let eventStore = EKEventStore()
    var circulares = [CircularTodas]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTituloParte1.type = .continuous
        lblTituloParte1.scrollDuration = 8.0
        lblTituloParte1.animationCurve = .easeOut
        lblTituloParte1.fadeLength = 10.0
        lblTituloParte1.leadingBuffer = 30.0
        lblTituloParte1.trailingBuffer = 20.0
       
        imbCalendario.isHidden=true
        
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
        viaNotif = UserDefaults.standard.integer(forKey: "viaNotif")
        horaInicialIcs = UserDefaults.standard.string(forKey: "horaInicialIcs") ?? "0"
        horaFinalIcs = UserDefaults.standard.string(forKey: "horaFinalIcs") ?? "0"
        fechaIcs = UserDefaults.standard.string(forKey: "fechaIcs") ?? "0"
        nivel = UserDefaults.standard.string(forKey: "nivel") ?? "0"
        
        if(horaInicialIcs != "00:00:00"){
            imbCalendario.isHidden=false
        }
         lblNivel.text = nivel
        
        if (viaNotif == 0){
            let titulo = UserDefaults.standard.string(forKey: "nombre") ?? ""
            circularTitulo = titulo
            let fecha = UserDefaults.standard.string(forKey: "fecha") ?? ""
            contenido = UserDefaults.standard.string(forKey:"contenido") ?? ""
            id = UserDefaults.standard.string(forKey: "id") ?? ""
            idInicial = Int(UserDefaults.standard.string(forKey: "id") ?? "0")!
            
                   let anio = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                   let mes = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                   let dia = fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                   //lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
            let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
            dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
            let d = dateFormatter.string(from: date1!)
            lblFechaCircular.text = d
                    //Convertir la fecha al formato dd de mes de año
                    
            
                   self.title = "Circular"
                   self.lblTituloParte1.text = titulo.uppercased()
                   //partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:titulo)
            
        }else{
            id = UserDefaults.standard.string(forKey: "idCircularViaNotif") ?? ""
            idInicial = Int(UserDefaults.standard.string(forKey: "idCircularViaNotif") ?? "0")!
            obtenerCircular(uri: urlBase+metodo_circular+"?id="+id)
           
        }
       
        
        if(ConexionRed.isConnectedToNetwork()){
           
            /*var attributedString = NSMutableAttributedString(string: "<p>Esta es una prueba</p><br><b>TEST</b>")
            lblContenidoHTML.isHidden=false
            webView.isHidden=true
            lblContenidoHTML.attributedText=attributedString
            */
           
            
          lblContenidoHTML.isHidden=true
          webView.isHidden=false
            
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
                  
                 
                  posicion = find(value: id,in: ids) ?? 0
                  
                 
                  self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
            
            
        }else{
            
            //contenido = contenido.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
            lblContenidoHTML.isHidden=true
            webView.isHidden=false
            
            webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'></head><body {color: #005188;}><h3>\(contenido)</h3></p></body></html>", baseURL: nil)
            
            
           /* let messageString = "<!DOCTYPE html><html><body><h3>"+contenido+"</h3></p></body></html>"
            
            
            let htmlData = NSString(string: messageString).data(using: String.Encoding.utf8.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString = try! NSAttributedString(data: htmlData!,
            options: options,
            documentAttributes: nil)
            lblContenidoHTML.attributedText = attributedString*/
            
            /*
             contenidoCircular = Html.fromHtml(contenidoCircular).toString();
             wvwDetalleCircular.loadData(contenidoCircular,"text/html", Xml.Encoding.UTF_8.toString());
             
             guard let data = contenido.data(using: .utf8) else {
                print("No se pudo convertir")
                return
            }
            let url:NSURL?=nil
            webView.load(data, mimeType: "text/html", characterEncodingName: "UTF8", baseURL: url! as URL)*/
            
        }
        
      
        /*
         <html>
           <head>
             <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=5,user-scalable=yes">
         <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
         <meta name="HandheldFriendly" content="true">
          
           </head>
          <body {color: #005188;}>
             <style>
             @font-face {font-family: GothamRoundedMedium; src: url('GothamRoundedBook_21018.ttf'); }
             h3 {
                  font-family: GothamRoundedMedium;
                  color:#0E2455;
               }
             </style>
             <h3>
                 
             <p>
         */
        
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
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_MX_POSIX")
        dateFormatter.dateFormat = dateFormat
        print("\(fechaIcs)'T'\(horaInicioIcs)")
        let calendar = calendario[0]
        let startDate = dateFormatter.date(from: "\(fechaIcs)T\(horaInicioIcs)")
        let eDate = dateFormatter.date(from:"\(fechaIcs)T\(horaFinIcs)")
        print("fecha \(startDate)")
         print("fecha \(eDate)")
        let endDate = eDate
        let event = EKEvent(eventStore: store)
        event.calendar = calendar
        event.title = titulo.uppercased()
        event.startDate = startDate
        event.endDate = eDate

        do {
            try store.save(event, span: .thisEvent)
            print("Evento guardado")
        }
        catch {
           print("Error guardando el evento")
            
        }
        
        
    }
    
    
    
    @IBAction func insertaEventoClick(_ sender: UIButton) {
       
        
        
        if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar este evento a tu calendario?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
              
                
                
                let eventStore = EKEventStore()
                           switch EKEventStore.authorizationStatus(for: .event) {
                           case .authorized:
                            self.insertarEvento(store: eventStore, titulo: self.circularTitulo, fechaIcs: self.fechaIcs, horaInicioIcs: self.horaInicialIcs, horaFinIcs: self.horaFinalIcs, ubicacionIcs: "")
                               case .denied:
                                   print("Acceso denegado")
                               case .notDetermined:
                               // 3
                                   eventStore.requestAccess(to: .event, completion:
                                     {[weak self] (granted: Bool, error: Error?) -> Void in
                                         if granted {
                                            self?.insertarEvento(store: eventStore, titulo: self?.circularTitulo ?? "", fechaIcs: self?.fechaIcs ?? "", horaInicioIcs: self?.horaInicialIcs ?? "", horaFinIcs: self?.horaFinalIcs ?? "", ubicacionIcs: "")
                                         } else {
                                               print("Acceso denegado")
                                         }
                                   })
                                   default:
                                       print("Case default")
                    
                    
                }
                
                
                
                
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
    
    
    
    
        
 
    
    @IBAction func btnNextClick(_ sender: UIButton) {
       //obtener la posición del elemento cargado
        posicion = posicion+1
        
        print("Cuenta: \(ids.count)")
        
        if(posicion<ids.count){
            var nextId = ids[posicion]
            var nextTitulo = titulos[posicion]
            var nextFecha = fechas[posicion]
            
            var nextHoraIniIcs = horasInicioIcs[posicion]
            var nextHoraFinIcs = horasFinIcs[posicion]
            var nextFechaIcs = fechasIcs[posicion]
            var nextNivel = niveles[posicion]
            
            if(nextHoraIniIcs != "00:00:00"){
                imbCalendario.isHidden=false
            }
             lblNivel.text = nextNivel
            
            circularTitulo = nextTitulo
            let link = URL(string:urlBase+"getCircularId2.php?id=\(nextId)")!
            let request = URLRequest(url: link)
            circularUrl = urlBase+"getCircularId2.php?id=\(nextId)"
            webView.load(request)
            self.title = "Circular"
            //nextTitulo.uppercased()
            
            let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
            let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
            let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
            //self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
            
            let dateFormatter = DateFormatter()
                      dateFormatter.dateFormat = "dd/MM/yyyy"
                      dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                      let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                      dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                      let d = dateFormatter.string(from: date1!)
                      lblFechaCircular.text = d
            
            
            self.lblTituloParte1.text=nextTitulo /*partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:nextTitulo.uppercased())*/
            id = nextId;
        }else{
            posicion = 0
            id = UserDefaults.standard.string(forKey: "id") ?? ""
        }
        
    }
        
        
        
        
    
    
    
    @IBAction func btnAntClick(_ sender: UIButton) {
        posicion = posicion-1
        print("Anterior...")
        if(posicion>=0){
            var nextId = ids[posicion]
            var nextTitulo = titulos[posicion]
            var nextFecha = fechas[posicion]
            
            var nextHoraIniIcs = horasInicioIcs[posicion]
            var nextHoraFinIcs = horasFinIcs[posicion]
            var nextFechaIcs = fechasIcs[posicion]
            var nextNivel = niveles[posicion]
            
            if(nextHoraIniIcs != "00:00:00"){
                imbCalendario.isHidden=false
            }
            
            lblNivel.text = nextNivel
            
            
             circularTitulo = nextTitulo
            let link = URL(string:urlBase+"getCircularId2.php?id=\(nextId)")!
            circularUrl = urlBase+"getCircularId2.php?id=\(nextId)"
            let request = URLRequest(url: link)
            webView.load(request)
            self.title = "Circular"
           let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
           let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
           let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
           //self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
            
                      let dateFormatter = DateFormatter()
                      dateFormatter.dateFormat = "dd/MM/yyyy"
                      dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                      let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                      dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                      let d = dateFormatter.string(from: date1!)
                      lblFechaCircular.text = d
            
            self.lblTituloParte1.text=nextTitulo /*partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:nextTitulo.uppercased())*/
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
        //var link:String=""
        //Crear el link mediante bit.ly, para pruebas
        circularUrl = "https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularId2?id=\(id)"
        compartir(message:"Compartir",link:circularUrl)
        /*Bitly.shorten(circularUrl) { response, error in
            var link = response?.bitlink ?? ""
            self.compartir(message:"Compartir",link:link)
            
            print(response?.bitlink)
            print(response?.applink)
            print(response?.statusCode)
            print(response?.statusText)
        }*/
        
        /*guard let link = URL(string: circularUrl) else { return }
        let dynamicLinksDomainURIPrefix:String = "https://chmd1.page.link/"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "mx.edu.CHMD1")
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "mx.edu.chmd1")
        
        guard let longDynamicLink = linkBuilder?.url else { return }
        print("The long URL is: \(longDynamicLink)")
        
        
        linkBuilder?.shorten() { url, warnings, error in
          guard let url = url, error != nil else { return }
          print("The short URL is: \(url)")
        }
        */
        
        
        
    }
    
    
   func compartir(message: String, link: String) {
       if let link = NSURL(string: link) {
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
                
                //Pasar a la siguiente
                
                self.posicion = self.posicion+1
                
              
                
                if(self.posicion<self.ids.count){
                    var nextId = self.ids[self.posicion]
                    var nextTitulo = self.titulos[self.posicion]
                    var nextFecha = self.fechas[self.posicion]
                    
                    var nextHoraIniIcs = self.horasInicioIcs[self.posicion]
                    var nextHoraFinIcs = self.horasFinIcs[self.posicion]
                    var nextFechaIcs = self.fechasIcs[self.posicion]
                    var nextNivel = self.niveles[self.posicion]
                    
                    if(nextHoraIniIcs != "00:00:00"){
                        self.imbCalendario.isHidden=false
                    }
                     self.lblNivel.text = nextNivel
                    
                    self.circularTitulo = nextTitulo
                    let link = URL(string:self.urlBase+"getCircularId2.php?id=\(nextId)")!
                    let request = URLRequest(url: link)
                    self.circularUrl = self.urlBase+"getCircularId2.php?id=\(nextId)"
                    self.webView.load(request)
                    self.title = "Circular"
                    //nextTitulo.uppercased()
                    
                    let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                    let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                    let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                    self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
                    
                    
                    self.lblTituloParte1.text=nextTitulo /*partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:nextTitulo.uppercased())*/
                    self.id = nextId;
                }else{
                    self.posicion = 0
                    self.id = UserDefaults.standard.string(forKey: "id") ?? ""
                }
                
                
                
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
                      guard let fecha = diccionario["updated_at"] as? String else {
                                                                          print("No se pudo obtener la fecha")
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
                                              
                                              //Esto si viene null desde el servicio web
                                                                var nv:String?
                                                                     if (diccionario["nivel"] == nil){
                                                                         nv=""
                                                                     }else{
                                                                         nv=diccionario["nivel"] as? String
                                                                     }
                        
                        
                     self.ids.append(id)
                     self.titulos.append(titulo)
                     self.fechas.append(fecha)
                        
                    self.fechasIcs.append(fechaIcs)
                    self.horasInicioIcs.append(horaInicioIcs)
                    self.horasFinIcs.append(horaFinIcs)
                    self.niveles.append(nv ?? "")
                }
                
                
            
        
    }
        
 }
    
        
}
    
  func obtenerCircular(uri:String){
          
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
                        guard let fecha = diccionario["updated_at"] as? String else {
                                                     print("No se pudo obtener la fecha")
                                                     return
                                                 }
                        self.ids.append(id)
                        self.titulos.append(titulo)
                        self.fechas.append(fecha)
                  }
                    
                    let anio = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                    let mes = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                    let dia = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                    self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
                    self.title = "Detalles de la circular"
                    //self.titulos[0].uppercased()
                    self.lblTituloParte1.text=self.titulos[0].uppercased() /*self.partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:self.titulos[0].uppercased())*/
              
          
      }
                
                
             
                
          
   }
      
          
    
          
          
      
      
  }
    
   
    func partirTitulo(label1:UILabel, label2:UILabel, titulo:String){
        var totalElementos:Int=0
        var tituloArreglo = titulo.split{$0 == " "}.map(String.init)
        totalElementos = tituloArreglo.count
        if(totalElementos>2){
            label1.text = tituloArreglo[0]+" "+tituloArreglo[1]
            var t:String=""
            var i:Int=0
            for i in 2...totalElementos-1{
                t += tituloArreglo[i]+" "
            }
            label2.text = t
            label2.isHidden = false
        }else{
             label2.isHidden = true
            label1.text = titulo
        }
    }
    
}

    


