//
//  PrincipalTableViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/6/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleSignIn
import Alamofire


extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


class PrincipalTableViewController: UITableViewController {
    //var avPlayer:AVPlayer!
    //var avPlayerLayer:AVPlayerLayer!
    //var paused:Bool = false
    
    @IBOutlet var tableViewMenu: UITableView!
    
    var menu = [MenuPrincipal]()
    var resp = [Responsable]()
    let base_url_foto:String="http://chmd.chmd.edu.mx:65083/CREDENCIALES/padres/"
    let base_url:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/";
    let get_usuario:String="getUsuarioEmail.php";
    var email:String="";
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        email="jacozon@gmail.com";
        //email = UserDefaults.standard.string(forKey: "email") ?? ""
        print("correo:"+email)
        
        let INICIO=1
        let MAGUEN=2
        let SIGN_OUT=3
        let CREDENCIAL=4
 
            
            menu.append(MenuPrincipal(id: INICIO, nombre: "Circulares", imagen:UIImage.init(named: "circulares")!))
            menu.append(MenuPrincipal(id: MAGUEN, nombre: "Mi Maguén", imagen:UIImage.init(named: "mi_maguen")!))
            menu.append(MenuPrincipal(id: CREDENCIAL, nombre: "Mi Credencial", imagen:UIImage.init(named: "credencial01")!))
            menu.append(MenuPrincipal(id: SIGN_OUT, nombre: "Cerrar Sesión", imagen:UIImage.init(named: "appmenu07")!))
        
    
        /*let urlVideo = Bundle.main.url(forResource: "video_app", withExtension: "mp4")
        
        avPlayer = AVPlayer(url: urlVideo!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear;
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: Selector("playerItemDidReachEnd:"),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    
    */
        
        
        obtenerDatosUsuario(uri:base_url+get_usuario+"?correo="+email)
        
    
    }

    /*@objc func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero)
    }*/
    
    
    func obtenerDatosUsuario(uri:String){
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
                    print(diccionario)
                    
                    /*
                                           * [{"id":"1","nombre":"SITT COHEN RAUL","numero":"0244","telefono":"52-51-91-34",
                                           * "correo":"raul@gconcreta.com","calle":"Ahuehuetes Nte. 1333- T. Vendome 304",
                                           * "colonia":"Bosques De Las Lomas","cp":"11700","ent":"CUDAD DE MEXICO","familia":"SITT SASSON",
                                           * "estatus":"2","fecha":"2019-08-22 16:36:03","tipo":"3","correo2":"raul@gconcreta.com",
                                           * "fotografia":"C:\\IDCARDDESIGN\\CREDENCIALES\\padres\\rosa maya.JPG","celular":"04455-51002067","token":"",
                                           * "vigencia":"1","responsable":"PADRE","ntarjeton1":"0","ntarjeton2":"0","perfil_admin":"0"}]
                                           * */
                    
                    
                    guard let id = diccionario["id"] as? String else {
                        print("No se pudo obtener el codigo")
                        return
                    }
                    
                    guard let nombre = diccionario["nombre"] as? String else {
                                           print("No se pudo obtener el codigo")
                                           return
                    }
                    
                    guard let numero = diccionario["numero"] as? String else {
                                           print("No se pudo obtener el numero")
                                           return
                    }
                    
                    guard let familia = diccionario["familia"] as? String else {
                                                              print("No se pudo obtener el numero")
                                                              return
                                       }
                    
                    guard let fotografia = diccionario["fotografia"] as? String else {
                                                              print("No se pudo obtener el numero")
                                                              return
                                       }
                    
                    guard let responsable = diccionario["responsable"] as? String else {
                                           print("No se pudo obtener el numero")
                                           return
                    }
                    
                    var foto:String = ""
                    
                    if(fotografia.count>5){
                        foto = self.base_url_foto+fotografia.components(separatedBy: "\\")[4]
                    }else{
                        foto = self.base_url_foto+"sinfoto.png"
                    }
                    
                    
                    
                    
                    var fotoUrl=foto;
                    //Guardar las variables
                    self.resp.append(Responsable(id:id,nombre:nombre,numero:numero,familia:familia,foto:foto,responsable: responsable))
                    
                    
                    UserDefaults.standard.set(id, forKey: "idUsuario")
                    UserDefaults.standard.set(nombre, forKey: "nombreUsuario")
                    UserDefaults.standard.set(numero, forKey: "numeroUsuario")
                    UserDefaults.standard.set(familia, forKey: "familia")
                    UserDefaults.standard.set(fotoUrl, forKey: "fotoUrl")
                    UserDefaults.standard.set(responsable, forKey: "responsable")
                  
                    
                    
                    }
                }
                
        }
        
    
    }
    
    /*
    
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
                    guard let eliminada = diccionario["eliminada"] as? String else {
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
                    self.guardarCirculares(idCircular: Int(id)!, idUsuario: 1660, nombre: titulo, textoCircular: "", no_leida: noLeida, leida: Int(leido)!, favorita: Int(favorito)!, compartida: Int(compartida)!, eliminada: Int(eliminada)!)
                }
                
                self.tableViewCirculares.reloadData()
            }
    
    */
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menu.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
            as! PrincipalTableViewCell
        let m = menu[indexPath.row]
        cell.lblMenu.text?=m.nombre
        //cell.lblMenu.font = UIFont(name: "Avenir-Light", size: 15.0)
        cell.imgMenu.image=m.imagen
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let valor = menu[indexPath.row]
        
        if (valor.id==1){
            performSegue(withIdentifier: "inicioSegue", sender: self)
        }
        if (valor.id==2){
            performSegue(withIdentifier: "webSegue", sender: self)
        }
        if(valor.id==3){
            if GIDSignIn.sharedInstance()?.currentUser != nil {
                GIDSignIn.sharedInstance()?.signOut()
                performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
            }
        }
        
        if (valor.id==4){
            performSegue(withIdentifier: "credencialSegue", sender: self)
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //avPlayer.play()
        //paused = false
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //avPlayer.pause()
        //paused = true
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
    
}

