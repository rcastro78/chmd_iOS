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
import SQLite3

extension UIView {

    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}



class CircularDetalleViewController: UIViewController {

    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var btnAnterior: UIButton!
    @IBOutlet weak var btnSiguiente: UIButton!
    
    @IBOutlet weak var lblFechaCircular: UILabel!
    @IBOutlet weak var lblTituloParte1: MarqueeLabel!
    @IBOutlet weak var lblTituloParte2: UILabel!
    @IBOutlet weak var lblTituloNivel: UILabel!
    @IBOutlet weak var imbCalendario: UIButton!
      
    @IBOutlet weak var btnCalendario: UIButton!
    //@IBOutlet weak var lblContenidoHTML: UITextView!
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
    var nextHoraIcs=""
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
    var metodo_circular="getCircularId4.php"
    var contenido:String=""
    let eventStore = EKEventStore()
    var circulares = [CircularTodas]()
    var idCirculares = [Int]()
    var db: OpaquePointer?
    var tipoCircular:Int=0
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        
        tipoCircular = UserDefaults.standard.integer(forKey: "tipoCircular")
        imbCalendario.isHidden=true
        idUsuario = UserDefaults.standard.string(forKey: "idUsuario") ?? "0"
        viaNotif = UserDefaults.standard.integer(forKey: "viaNotif")
        horaInicialIcs = UserDefaults.standard.string(forKey: "horaInicialIcs") ?? "00:00:00"
        horaFinalIcs = UserDefaults.standard.string(forKey: "horaFinalIcs") ?? "0"
        fechaIcs = UserDefaults.standard.string(forKey: "fechaIcs") ?? "0"
        nivel = UserDefaults.standard.string(forKey: "nivel") ?? "0"
        
        
         if(horaInicialIcs != "00:00:00"){
            imbCalendario.isHidden=false
            btnCalendario.isHidden=false
            btnCalendario.isUserInteractionEnabled=false
         }else{
            imbCalendario.isHidden=true
            btnCalendario.isHidden=true
            btnCalendario.isUserInteractionEnabled=true
         }
         lblNivel.text = nivel
        
        if (viaNotif == 0){
            let titulo = UserDefaults.standard.string(forKey: "nombre") ?? ""
            circularTitulo = titulo
            let fecha = UserDefaults.standard.string(forKey: "fecha") ?? ""
            contenido = UserDefaults.standard.string(forKey:"contenido") ?? ""
            id = UserDefaults.standard.string(forKey: "id") ?? ""
            idInicial = Int(UserDefaults.standard.string(forKey: "id") ?? "0")!
            
            //self.title = "Circular"
            let bannerWidth = navigationItem.accessibilityFrame.size.width
            
            let bannerX = bannerWidth / 2
            
            
            let imageView = UIImageView(frame: CGRect(x: bannerX, y: 10, width: 24, height: 24))
            imageView.contentMode = .scaleAspectFit
            let image = UIImage(named: "chmd_barra")
            imageView.image = image
            navigationItem.titleView = imageView
            
            
            if(!ConexionRed.isConnectedToNetwork()){
               leerCirculares()
            }
            
                   
                   //partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:titulo)
            
        }else{
            id = UserDefaults.standard.string(forKey: "idCircularViaNotif") ?? ""
            idInicial = Int(UserDefaults.standard.string(forKey: "idCircularViaNotif") ?? "0")!
            obtenerCircular(uri: urlBase+"getCircularId4.php?id="+id)
           
        }
        
        if(ConexionRed.isConnectedToNetwork()){
         
          webView.isHidden=false
            
            let link = URL(string:urlBase+"getCircularId4.php?id=\(id)")!
                  let request = URLRequest(url: link)
                  //webView = WKWebView(frame: .zero, configuration: webConfiguration)
                  webView.load(request)
                  webView.scrollView.isScrollEnabled = true
                  webView.scrollView.bounces = false
                  webView.allowsBackForwardNavigationGestures = false
                  webView.contentMode = .scaleToFill
                    
            
                  let address=urlBase+"getCircularesUsuarios.php?usuario_id=\(idUsuario)"
                  circularUrl = address
                  if ConexionRed.isConnectedToNetwork() == true {
                    
                    //Todas
                    if(tipoCircular==1){
                       let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesUsuarioLazyLoad.php?usuario_id=\(idUsuario)&limit=50"
                            let _url = URL(string: address);
                        self.obtenerCirculares2(uri:address)
                    }
                    
                    //Favoritas
                    if(tipoCircular==2){
                        let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesFavoritas.php?usuario_id=\(idUsuario)"
                            let _url = URL(string: address);
                            self.obtenerCirculares(uri:address)
                    }
                    //No leidas
                    if(tipoCircular==3){
                     let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesNoLeidas.php?usuario_id=\(idUsuario)"
                      let _url = URL(string: address);
                      self.obtenerCirculares(uri:address)
                  }
                    
                    //Papelera
                      if(tipoCircular==4){
                       let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularesEliminadas.php?usuario_id=\(idUsuario)"
                        let _url = URL(string: address);
                        self.obtenerCirculares(uri:address)
                    }
                    
                    
                }
                  
                 
                  posicion = find(value: id,in: ids) ?? 0
                
                    //Solo cuando sea no leída
                
                  self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
            
                
            
            
        }else{
            let anio = circulares[posicion].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
            let mes = circulares[posicion].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
            let dia = circulares[posicion].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
            
                            let dateFormatter = DateFormatter()
                           dateFormatter.dateFormat = "dd/MM/yyyy"
                           dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                           let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                           dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                           let d = dateFormatter.string(from: date1!)
            webView.isHidden=false
            
             webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'><meta content='text/html;charset=utf-8'></head><body {color: #005188;}><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(circulares[posicion].nivel)</h5></div><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(d)</h5></div><h3>\(circulares[posicion].contenido.replacingOccurrences(of: "&aacute;", with: "á").replacingOccurrences(of: "&eacute;", with: "é").replacingOccurrences(of: "&iacute;", with: "í").replacingOccurrences(of: "&oacute;", with: "ó").replacingOccurrences(of: "&uacuﬁte;", with: "ú").replacingOccurrences(of: "&ordm;", with: "o."))</h3></p></body></html>", baseURL: nil)
          
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
            //self.showToast(message:"Evento guardado", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
        }
        catch {
           print("Error guardando el evento")
            
        }
        
        
    }
    
    
    
    @IBAction func btnCalendarioClick(_ sender: Any) {
        if(ConexionRed.isConnectedToNetwork()){
               
                let eventStore = EKEventStore()
                           switch EKEventStore.authorizationStatus(for: .event) {
                           case .authorized:
                            self.insertarEvento(store: eventStore, titulo: self.circularTitulo, fechaIcs: self.fechaIcs, horaInicioIcs: self.horaInicialIcs, horaFinIcs: self.horaFinalIcs, ubicacionIcs: "")
                            self.showToast(message:"Evento guardado", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
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
                
              
          
        }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                       alert.show()
        }
    }
    @IBAction func insertaEventoClick(_ sender: UIButton) {
       
        
        
        
        
    }
    
    
    
    
        
   var p = UserDefaults.standard.integer(forKey:"posicion")
    @IBAction func btnSiguienteClick(_ sender: Any) {
        if(ConexionRed.isConnectedToNetwork()){
             print("posicion \(p)")
             p = p+1
            if(p >= ids.count){
              btnSiguiente.isUserInteractionEnabled=false
            }
            
            if(p<ids.count){
               
                var nextId = ids[p]
                
               self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: nextId)
                
                var nextTitulo = titulos[p]
                var nextFecha = fechas[p]
                
                var nextHoraIniIcs = horasInicioIcs[p]
                nextHoraIcs = horasInicioIcs[p]
                var nextHoraFinIcs = horasFinIcs[p]
                var nextFechaIcs = fechasIcs[p]
                var nextNivel = niveles[p]
                
                if(nextHoraIniIcs != "00:00:00"){
                    imbCalendario.isHidden=false
                }
        
                
                circularTitulo = nextTitulo
                let link = URL(string:urlBase+"getCircularId4.php?id=\(nextId)")!
                let request = URLRequest(url: link)
                circularUrl = urlBase+"getCircularId4.php?id=\(nextId)"
                webView.load(request)
                self.title = "Circular"
               
                id = nextId;
            }else{
       
            }
                
                
            
           
            
        }else{
            //No hay conexion
            
            if(p<circulares.count){
               p = p+1
                if(p>=circulares.count){
                    p = 0
                }
               
                let anio = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                let mes = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                let dia = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                
                
                var nextHoraIniIcs = circulares[p].horaInicialIcs
                var nextHoraFinIcs = circulares[p].horaFinalIcs
                var nextFechaIcs = circulares[p].fechaIcs
                if(nextHoraIniIcs != "00:00:00"){
                    imbCalendario.isHidden=false
                    btnCalendario.isHidden=false
                }else{
                    imbCalendario.isHidden=true
                    btnCalendario.isHidden=true
                }
                
               let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                let d = dateFormatter.string(from: date1!)
                
                
                webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'><meta content='text/html;charset=utf-8'></head><body {color: #005188;}><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(circulares[p].nivel)</h5></div><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(d)</h5></div><h3>\(circulares[p].contenido.replacingOccurrences(of: "&aacute;", with: "á").replacingOccurrences(of: "&eacute;", with: "é").replacingOccurrences(of: "&iacute;", with: "í").replacingOccurrences(of: "&oacute;", with: "ó").replacingOccurrences(of: "&uacuﬁte;", with: "ú").replacingOccurrences(of: "&ordm;", with: "o."))</h3></p></body></html>", baseURL: nil)
                
            
            }
          
            
        }
    }
    
  
    @IBAction func btnNextClick(_ sender: UIButton) {
       //obtener la posición del elemento cargado
       print("posicion \(p)")
       if(ConexionRed.isConnectedToNetwork()){
       p = p+1
        if(p >= ids.count){
            btnSiguiente.isUserInteractionEnabled=false
        }
        if(p<ids.count){
            
            var nextId = ids[p]
            print("id siguiente: \(nextId)")
            print("pos siguiente: \(p)")
             self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: nextId)
            
            var nextTitulo = titulos[p]
            var nextFecha = fechas[p]
            
            var nextHoraIniIcs = horasInicioIcs[p]
            var nextHoraFinIcs = horasFinIcs[p]
            var nextFechaIcs = fechasIcs[p]
            var nextNivel = niveles[p]
            nextHoraIcs = horasInicioIcs[p]
            if(nextHoraIniIcs != "00:00:00"){
                imbCalendario.isHidden=false
                btnCalendario.isHidden=false
            }else{
                imbCalendario.isHidden=true
                btnCalendario.isHidden=true
            }
           
            
            circularTitulo = nextTitulo
            let link = URL(string:urlBase+"getCircularId4.php?id=\(nextId)")!
            let request = URLRequest(url: link)
            circularUrl = urlBase+"getCircularId4.php?id=\(nextId)"
            webView.load(request)
            self.title = "Circular"
            //nextTitulo.uppercased()
            
            let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
            let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
            let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
          
           
            id = nextId;
        }else{
            
        }
            
            
        
       
        
    }else{
        //No hay conexion
        
        if(p<circulares.count){
           p = p+1
            if(p>=circulares.count){
                p = 0
            }
            //lblTituloParte1.text = circulares[posicion].nombre
            //lblNivel.text = circulares[posicion].nivel
            
            let anio = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
            let mes = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
            let dia = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
            
            
            var nextHoraIniIcs = circulares[p].horaInicialIcs
            var nextHoraFinIcs = circulares[p].horaFinalIcs
            var nextFechaIcs = circulares[p].fechaIcs
            if(nextHoraIniIcs != "00:00:00"){
                imbCalendario.isHidden=false
                btnCalendario.isHidden=false
            }else{
                imbCalendario.isHidden=true
                btnCalendario.isHidden=true
            }
            
           let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
            let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
            dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
            let d = dateFormatter.string(from: date1!)
            //lblFechaCircular.text = d
            
           webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'><meta content='text/html;charset=utf-8'></head><body {color: #005188;}><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(circulares[p].nivel)</h5></div><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(d)</h5></div><h3>\(circulares[p].contenido.replacingOccurrences(of: "&aacute;", with: "á").replacingOccurrences(of: "&eacute;", with: "é").replacingOccurrences(of: "&iacute;", with: "í").replacingOccurrences(of: "&oacute;", with: "ó").replacingOccurrences(of: "&uacuﬁte;", with: "ú").replacingOccurrences(of: "&ordm;", with: "o."))</h3></p></body></html>", baseURL: nil)
            
        
        }
      
        
    }
        
    }
        
        
    
    
    @IBAction func btnAnteriorClick(_ sender: Any) {
        if(ConexionRed.isConnectedToNetwork()){
                   p = p-1
                    if(p<0){
                        p=0
                    }
                   print("Anterior...")
                   if(p>=0){
                       var nextId = ids[p]
                       var nextTitulo = titulos[p]
                       var nextFecha = fechas[p]
                        self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id: nextId)
                       var nextHoraIniIcs = horasInicioIcs[p]
                       var nextHoraFinIcs = horasFinIcs[p]
                       var nextFechaIcs = fechasIcs[p]
                       var nextNivel = niveles[p]
                       nextHoraIcs = horasInicioIcs[p]
                       if(nextHoraIniIcs != "00:00:00"){
                           imbCalendario.isHidden=false
                           btnCalendario.isHidden=false
                       }else{
                           imbCalendario.isHidden=true
                           btnCalendario.isHidden=true
                       }
                       
                     
                       
                       
                        circularTitulo = nextTitulo
                       let link = URL(string:urlBase+"getCircularId4.php?id=\(nextId)")!
                       circularUrl = urlBase+"getCircularId4.php?id=\(nextId)"
                       let request = URLRequest(url: link)
                       webView.load(request)
                       self.title = "Circular"
                      let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                      let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                      let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                     
                       
                       id = nextId
                   }else{
                       p = ids.count
                   }
               }else{
                      
                      p = p-1
                   if(p>0){
                       //lblTituloParte1.text = circulares[posicion].nombre
                       //               lblNivel.text = circulares[posicion].nivel
                                      
                                      let anio = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                                      let mes = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                                      let dia = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                                      
                                     let dateFormatter = DateFormatter()
                                      dateFormatter.dateFormat = "dd/MM/yyyy"
                                      dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                                      let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                                      dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                                      let d = dateFormatter.string(from: date1!)
                                      
                                      var nextHoraIniIcs = circulares[p].horaInicialIcs
                                                 var nextHoraFinIcs = circulares[p].horaFinalIcs
                                                 var nextFechaIcs = circulares[p].fechaIcs
                                                 if(nextHoraIniIcs != "00:00:00"){
                                                            imbCalendario.isHidden=false
                                                 }else{
                                                            imbCalendario.isHidden=true
                                                 }
                                      webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'><meta content='text/html;charset=utf-8'></head><body {color: #005188;}><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(circulares[p].nivel)</h5></div><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(d)</h5></div><h3>\(circulares[p].contenido.replacingOccurrences(of: "&aacute;", with: "á").replacingOccurrences(of: "&eacute;", with: "é").replacingOccurrences(of: "&iacute;", with: "í").replacingOccurrences(of: "&oacute;", with: "ó").replacingOccurrences(of: "&uacuﬁte;", with: "ú").replacingOccurrences(of: "&ordm;", with: "o."))</h3></p></body></html>", baseURL: nil)
                                   
                              }
                   }
    }
    
    @IBAction func btnAntClick(_ sender: UIButton) {
        
        if(ConexionRed.isConnectedToNetwork()){
            p = p-1
            if(p<0){
                p=0
              btnAnterior.isUserInteractionEnabled=false
            }
            if(p>=0){
                var nextId = ids[p]
                var nextTitulo = titulos[p]
                var nextFecha = fechas[p]
                 self.leerCircular(direccion: self.urlBase+self.leerMetodo, usuario_id: self.idUsuario, circular_id:nextId)
                var nextHoraIniIcs = horasInicioIcs[p]
                var nextHoraFinIcs = horasFinIcs[p]
                var nextFechaIcs = fechasIcs[p]
                var nextNivel = niveles[p]
                nextHoraIcs = horasInicioIcs[p]
                if(nextHoraIniIcs != "00:00:00"){
                    imbCalendario.isHidden=false
                    btnCalendario.isHidden=false
                }else{
                    imbCalendario.isHidden=true
                    btnCalendario.isHidden=true
                }
                
                //lblNivel.text = nextNivel
                
                
                 circularTitulo = nextTitulo
                let link = URL(string:urlBase+"getCircularId4.php?id=\(nextId)")!
                circularUrl = urlBase+"getCircularId4.php?id=\(nextId)"
                let request = URLRequest(url: link)
                webView.load(request)
                self.title = "Circular"
               let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
               let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
               let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
               //self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
                
                          /*let dateFormatter = DateFormatter()
                          dateFormatter.dateFormat = "dd/MM/yyyy"
                          dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                          let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                          dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                          let d = dateFormatter.string(from: date1!)
                          lblFechaCircular.text = d*/
                
                
                if(ConexionRed.isConnectedToNetwork()){
                    //self.lblTituloParte1.isHidden=true
                    //self.lblTituloParte1?.visiblity(gone: true, dimension: 0)
                }
                
                //self.lblTituloParte1.text=nextTitulo
                id = nextId
            }else{
                p = ids.count
            }
        }else{
            p = p-1
            if(p>0){
                lblTituloParte1.text = circulares[p].nombre
                               lblNivel.text = circulares[p].nivel
                               
                               let anio = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                               let mes = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                               let dia = circulares[p].fecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                               
                              /*let dateFormatter = DateFormatter()
                               dateFormatter.dateFormat = "dd/MM/yyyy"
                               dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                               let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                               dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                               let d = dateFormatter.string(from: date1!)
                               lblFechaCircular.text = d*/
                               var nextHoraIniIcs = circulares[p].horaInicialIcs
                                          var nextHoraFinIcs = circulares[p].horaFinalIcs
                                          var nextFechaIcs = circulares[p].fechaIcs
                                          if(nextHoraIniIcs != "00:00:00"){
                                                     imbCalendario.isHidden=false
                                          }else{
                                                     imbCalendario.isHidden=true
                                          }
                
                
                
                            let dateFormatter = DateFormatter()
                              dateFormatter.dateFormat = "dd/MM/yyyy"
                              dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                              let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                              dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                              let d = dateFormatter.string(from: date1!)
                
                               webView.loadHTMLString("<html><head><meta name='viewport' content='width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1.0, user-scalable=yes'><meta  http-equiv='X-UA-Compatible'  content='IE=edge,chrome=1'><meta name='HandheldFriendly' content='true'><meta content='text/html;charset=utf-8'></head><body {color: #005188;}><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(circulares[p].nivel)</h5></div><div style='text-align:right; width:100%;text-color:#098FCF'><h5>\(d)</h5></div><h3>\(circulares[p].contenido.replacingOccurrences(of: "&aacute;", with: "á").replacingOccurrences(of: "&eacute;", with: "é").replacingOccurrences(of: "&iacute;", with: "í").replacingOccurrences(of: "&oacute;", with: "ó").replacingOccurrences(of: "&uacuﬁte;", with: "ú").replacingOccurrences(of: "&ordm;", with: "o."))</h3></p></body></html>", baseURL: nil)
                            
                       }
            }
            
        
    }
    
   
    
    @IBAction func btnFavoritoClick(_ sender: Any) {
        if(ConexionRed.isConnectedToNetwork()){
                   //let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar esta circular a tus favoritas?", preferredStyle: .alert)
                   
                   // Create OK button with action handler
                   //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                       self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: self.id)
                   //})
                   
                   // Create Cancel button with action handlder
                   //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                       
                   //}
                   
                   //Add OK and Cancel button to dialog message
                   //dialogMessage.addAction(ok)
                   //dialogMessage.addAction(cancel)
                   
                   // Present dialog message to user
                   //self.present(dialogMessage, animated: true, completion: nil)
               }else{
                   var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                              alert.show()
               }
    }
    
    
    @IBAction func btnFavClick(_ sender: UIButton) {
        //Hacer favorita la circular
        
        if(ConexionRed.isConnectedToNetwork()){
           // let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar esta circular a tus favoritas?", preferredStyle: .alert)
            
            // Create OK button with action handler
            //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: self.id)
            //})
            
            // Create Cancel button with action handlder
            //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                
            //}
            
            //Add OK and Cancel button to dialog message
            //dialogMessage.addAction(ok)
            //dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            //self.present(dialogMessage, animated: true, completion: nil)
        }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                       alert.show()
        }
        
        
        
        
    }
    
    @IBAction func btnCompartirClick(_ sender: UIButton) {
        //var link:String=""
        //Crear el link mediante bit.ly, para pruebas
        circularUrl = "https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularId4?id=\(id)"
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
       /*if let link = NSURL(string: link) {
           let objectsToShare = [message,link] as [Any]
           let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
           self.present(activityVC, animated: true, completion: nil)
       }*/
    
    let date = Date()
    let msg = message
    let urlWhats = "whatsapp://send?text=\(msg+"\n"+link)"

    if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
        if let whatsappURL = NSURL(string: urlString) {
            if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                UIApplication.shared.openURL(whatsappURL as URL)
            } else {
                print("Por favor instale whatsapp")
            }
        }
    }
    
   }
    
    
    
    @IBAction func btnNoLeerClick(_ sender: Any) {
        
         if(ConexionRed.isConnectedToNetwork()){
            //let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas marcar esta circular como no leída?", preferredStyle: .alert)
            
            // Create OK button with action handler
            //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
            //})
            
            // Create Cancel button with action handlder
            //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                
            //}
            
            //Add OK and Cancel button to dialog message
            //dialogMessage.addAction(ok)
            //dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            //self.present(dialogMessage, animated: true, completion: nil)
         }else{
            var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                                  alert.show()
        }

        
        
    }
    /*
    @IBAction func btnEliminaClick(_ sender: Any) {
        if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.delCircularSinDialogo(direccion: self.urlBase+self.delMetodo, usuario_id:self.idUsuario, circular_id: self.id)
                
                //Pasar a la siguiente
                
                self.posicion = self.posicion+1
                
                //if(self.posicion<self.ids.count){
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
                    let link = URL(string:self.urlBase+"getCircularId4.php?id=\(nextId)")!
                    let request = URLRequest(url: link)
                    self.circularUrl = self.urlBase+"getCircularId4.php?id=\(nextId)"
                    self.webView.load(request)
                    self.title = "Circular"
                    //nextTitulo.uppercased()
                    
                    let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                    let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                    let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                    self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
                    self.lblTituloParte1.text=nextTitulo
                    
                    
                    self.id = nextId;
               
                
                
                
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
    }*/
    
    @IBAction func btnEliminarClick(_ sender: UIButton) {
        
        if(ConexionRed.isConnectedToNetwork()){
            let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                self.delCircularSinDialogo(direccion: self.urlBase+self.delMetodo, usuario_id:self.idUsuario, circular_id: self.id)
                
                //Pasar a la siguiente
                
                self.posicion = self.posicion+1
                
                //if(self.posicion<self.ids.count){
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
                    let link = URL(string:self.urlBase+"getCircularId4.php?id=\(nextId)")!
                    let request = URLRequest(url: link)
                    self.circularUrl = self.urlBase+"getCircularId4.php?id=\(nextId)"
                    self.webView.load(request)
                    self.title = "Circular"
                    //nextTitulo.uppercased()
                    
                    /*let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                    let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                    let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    dateFormatter.locale = Locale(identifier: "es_ES_POSIX")
                    let date1 = dateFormatter.date(from: "\(dia)/\(mes)/\(anio)")
                    dateFormatter.dateFormat = "d 'de' MMMM 'de' YYYY"
                    let d = dateFormatter.string(from: date1!)
                    self.lblFechaCircular.text = d
                
                    self.lblTituloParte1.text=nextTitulo*/
                    
                    
                    self.id = nextId;
               
                
                
                
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
                self.showToast(message:"Marcada como favorita", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
                
            case .failure:
                print(Error.self)
                self.showToast(message:"Error", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
            }
        }
    }
    
    func leerCircular(direccion:String, usuario_id:String, circular_id:String){
        let parameters: Parameters = ["usuario_id": usuario_id, "circular_id": circular_id]      //This will be your parameter
        Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
            switch (response.result) {
            case .success:
                print(response)
                UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
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
                 self.showToast(message:"Marcada como no leída", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
                break
            case .failure:
                print(Error.self)
            }
        }
    }
    
    func delCircular(direccion:String, usuario_id:String, circular_id:String){
        
        let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas eliminar esta circular?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
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
    
    
    func delCircularSinDialogo(direccion:String, usuario_id:String, circular_id:String){
        
       
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
                        guard let eliminada = diccionario["eliminado"] as? String else {
                                                   return
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
                               guard let eliminada = diccionario["eliminado"] as? String else {
                                                          return
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
        
}
                
        
        
        func obtenerCirculares2(uri:String){
                   
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
                                   guard let eliminada = diccionario["eliminado"] as? String else {
                                                              return
                                                          }
                                if(Int(eliminada)==0){
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
                    
                    /*let anio = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                    let mes = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                    let dia = self.fechas[0].components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                    self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"
                    self.title = "Detalles de la circular"*/
                    //self.titulos[0].uppercased()
                    //self.lblTituloParte1.text=self.titulos[0].uppercased() /*self.partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:self.titulos[0].uppercased())*/
              
          
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
   
    
    
    
    @IBAction func mostrarMenu(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Opciones", message: "Elige la opción que deseas", preferredStyle: .actionSheet)
        let actionFav = UIAlertAction(title: "Agregar a favoritas", style: .default) { (action:UIAlertAction) in
           if(ConexionRed.isConnectedToNetwork()){
               //let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar esta circular a tus favoritas?", preferredStyle: .alert)
               
               // Create OK button with action handler
               //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                   self.favCircular(direccion: self.urlBase+"favCircular.php", usuario_id: self.idUsuario, circular_id: self.id)
               //})
               
               // Create Cancel button with action handlder
               //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                   
               //}
               
               //Add OK and Cancel button to dialog message
               //dialogMessage.addAction(ok)
               //dialogMessage.addAction(cancel)
               
               // Present dialog message to user
               //self.present(dialogMessage, animated: true, completion: nil)
           }else{
               var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                          alert.show()
           }
        }
        
        let actionNoLeer = UIAlertAction(title: "Marcar como no leída", style: .default) { (action:UIAlertAction) in
           if(ConexionRed.isConnectedToNetwork()){
                      //let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas marcar esta circular como no leída?", preferredStyle: .alert)
                      
                      // Create OK button with action handler
                      //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                          self.noleerCircular(direccion: self.urlBase+self.noleerMetodo, usuario_id: self.idUsuario, circular_id: self.id)
             self.showToast(message:"Marcada como favorita", font: UIFont(name:"GothamRounded-Bold",size:11.0)!)
                      //})
                      
                      // Create Cancel button with action handlder
                      //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                          
                      //}
                      
                      //Add OK and Cancel button to dialog message
                      //dialogMessage.addAction(ok)
                      //dialogMessage.addAction(cancel)
                      
                      // Present dialog message to user
                      //self.present(dialogMessage, animated: true, completion: nil)
                   }else{
                      var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                                            alert.show()
                  }
        }
        
        
        let actionEliminar = UIAlertAction(title: "Eliminar esta circular", style: .destructive) { (action:UIAlertAction) in
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
                       let link = URL(string:self.urlBase+"getCircularId4.php?id=\(nextId)")!
                       let request = URLRequest(url: link)
                       self.circularUrl = self.urlBase+"getCircularId4.php?id=\(nextId)"
                       self.webView.load(request)
                       self.title = "Circular"
                       //nextTitulo.uppercased()
                       
                       /*let anio = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[0]
                       let mes = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[1]
                       let dia = nextFecha.components(separatedBy: " ")[0].components(separatedBy: "-")[2]
                       self.lblFechaCircular.text = "\(dia)/\(mes)/\(anio)"*/
                       
                       if(ConexionRed.isConnectedToNetwork()){
                           self.lblTituloParte1.isHidden=true
                           self.lblTituloParte1?.visiblity(gone: true, dimension: 0)
                       }
                       
                       //self.lblTituloParte1.text=nextTitulo /*partirTitulo(label1:self.lblTituloParte1,label2:self.lblTituloParte2,titulo:nextTitulo.uppercased())*/
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
        
        let actionCompartir = UIAlertAction(title: "Compartir esta circular", style: .default) { (action:UIAlertAction) in
            
            let circularUrl = "https://www.chmd.edu.mx/WebAdminCirculares/ws/getCircularId4.php?id=\(self.id)"
            guard let link = URL(string: circularUrl) else { return }
            let dynamicLinksDomainURIPrefix = "https://chmd1.page.link"
            let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "mx.edu.CHMD1")
            linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "mx.edu.CHMD1")

            
               let options = DynamicLinkComponentsOptions()
               options.pathLength = .short
               linkBuilder?.options = options

               linkBuilder?.shorten { (shortURL, warnings, error) in

                   if let error = error {
                       print(error.localizedDescription)
                       return
                   }

                   let shortLink = shortURL
                   self.compartir(message: "Comparto la circular del colegio", link: "\(shortLink!)")
               }
            
            
            
            
        }
        
        let actionCalendario = UIAlertAction(title: "Agregar al calendario", style: .default) { (action:UIAlertAction) in
                   if(ConexionRed.isConnectedToNetwork()){
                              //let dialogMessage = UIAlertController(title: "CHMD", message: "¿Deseas agregar este evento a tu calendario?", preferredStyle: .alert)
                              
                              // Create OK button with action handler
                              //let ok = UIAlertAction(title: "Sí", style: .default, handler: { (action) -> Void in
                                
                                  
                                  
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
                                  
                                  
                                  
                                  
                              //})
                              
                              // Create Cancel button with action handlder
                              //let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (action) -> Void in
                                  
                              //}
                              
                              //Add OK and Cancel button to dialog message
                              //dialogMessage.addAction(ok)
                              //dialogMessage.addAction(cancel)
                              
                              // Present dialog message to user
                              //self.present(dialogMessage, animated: true, completion: nil)
                          }else{
                              var alert = UIAlertView(title: "No está conectado a Internet", message: "Esta opción solo funciona con una conexión a Internet", delegate: nil, cancelButtonTitle: "Aceptar")
                                         alert.show()
                          }
               }
        
        let actionCancelar = UIAlertAction(title: "Cancelar", style:.cancel) { (action:UIAlertAction) in
                 // self.dismiss(animated: true, completion: nil)
              }
        
        /*
         let action3 = UIAlertAction(title: "Destructive", style: .destructive) { (action:UIAlertAction) in
             print("You've pressed the destructive");
         }
         */
      
        alertController.addAction(actionFav)
        alertController.addAction(actionNoLeer)
        alertController.addAction(actionCompartir)
        alertController.addAction(actionEliminar)
        alertController.addAction(actionCancelar)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
}

    


