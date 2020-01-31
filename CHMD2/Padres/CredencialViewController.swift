//
//  CredencialViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 10/15/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire

import SDWebImage





class CredencialViewController: UIViewController {

    @IBOutlet weak var imgFotoPadre: UIImageView!
    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblParentesco: UILabel!
    @IBOutlet weak var lblNumFamilia: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    var urlFotos:String = "http://chmd.chmd.edu.mx:65083/CREDENCIALES/padres/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nombre = UserDefaults.standard.string(forKey: "nombreUsuario") ?? ""
        var responsable = UserDefaults.standard.string(forKey: "responsable") ?? ""
        var familia = UserDefaults.standard.string(forKey: "familia") ?? ""
        var fotoUrl = UserDefaults.standard.string(forKey: "fotoUrl") ?? ""
        lblNombre.text=nombre
        lblParentesco.text=responsable
        lblNumFamilia.text = familia
        
        //imgFotoPadre.downloaded(from:fotoUrl);
        
        //imgFotoPadre.sd_setShowActivityIndicatorView(true)
        //imgFotoPadre.sd_setIndicatorStyle(.gray)
        
        
        print(fotoUrl)
        print(nombre)
        print(responsable)
        
        let imageURL = URL(string: fotoUrl)!
          Alamofire.request(imageURL).responseJSON {
          response in

          let status = response.response?.statusCode
            if(status!>=200){
                let imagen = self.generarQR(from: self.urlFotos+"sinfoto.png")
                let imageURL = URL(string: self.urlFotos+"sinfoto.png")!
                self.imgFotoPadre.sd_setImage(with: imageURL)
                self.qrImage.image = imagen
            }else{
                let imagen = self.generarQR(from: fotoUrl)
                let imageURL = URL(string: fotoUrl)!
                let placeholderImageURL = URL(string: self.urlFotos+"sinfoto.png")!
                self.imgFotoPadre.sd_setImage(with: imageURL,placeholderImage:UIImage.init(named: "sinfoto.png"))
                self.qrImage.image = imagen
            }

        }
        
      
        
        
 
        
       
    }
    
    
    func generarQR(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    
    
    func obtenerCredencial(uri:String){
        
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

}
