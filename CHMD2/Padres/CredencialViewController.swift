//
//  CredencialViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 10/15/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit
import Alamofire
//import CryptoSwift
import RijndaelSwift
class CredencialViewController: UIViewController {

    @IBOutlet weak var imgFotoPadre: UIImageView!
    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblResponsable: UILabel!
    @IBOutlet weak var lblVigencia: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    var urlFotos:String = "http://chmd.chmd.edu.mx:65083/CREDENCIALES/padres/"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nombre = UserDefaults.standard.string(forKey: "nombreUsuario") ?? ""
        var responsable = UserDefaults.standard.string(forKey: "responsable") ?? ""
        var familia = UserDefaults.standard.string(forKey: "familia") ?? ""
        var vigencia = UserDefaults.standard.string(forKey: "vigencia") ?? ""
        var fotoUrl = UserDefaults.standard.string(forKey: "fotoUrl") ?? ""
        var cifrado = UserDefaults.standard.string(forKey: "cifrado") ?? ""
       
        lblNombre.text=nombre
        lblResponsable.text=responsable
        lblVigencia.text = "Vigente hasta: \(vigencia)"
        /*let cifrar = "1|1|3311"
        let llave = "SIAPMaguen200000"
        let iv = "HR$2pIjHR$2pIj12"
        let dLlave:Data? = llave.data(using: .utf8)
        let dIv:Data? = iv.data(using: .utf8)
        
        
       let plain = cifrar.data(using: .ascii)!
       let key = llave.data(using: .ascii)!
        let iv1 = iv.data(using: .ascii)!
       let r = Rijndael(key: key, mode: .cbc)!
       let cipher = r.encrypt(data: plain, blockSize: 16, iv: iv1)
        print("cifrado es: \(cipher)")
        print("cifrado es: \(Data(cipher!).base64EncodedString())")
        
        
        let bllave = llave.bytes
        let bcifrar = cifrar.bytes
        let biv = iv.bytes
       */
       /* do{
            
           var encryptor = try AES(key: llave, iv: iv).makeEncryptor()

            var ciphertext = Array<UInt8>()
            // aggregate partial results
            ciphertext += try encryptor.update(withBytes: Array(cifrar.utf8))
            ciphertext += try encryptor.finish()
            print("cifrado aes: \(Data(ciphertext).base64EncodedString())")
            print("cifrado aes: \(ciphertext.toHexString())")
        }catch{
            print(error)
        }
        do{
            //aes
            let encrypted = try AES(key: bllave, blockMode: CBC(iv: biv), padding: .pkcs5).encrypt(bcifrar)
            print("cifrado aes 5: \(Data(encrypted).base64EncodedString())")
        }catch{
            print(error)
        }
        
        
        do{
            //aes
            let encrypted = try AES(key: bllave, blockMode: CBC(iv: biv), padding: .pkcs7).encrypt(bcifrar)
            print("cifrado aes 7: \(Data(encrypted).base64EncodedString())")
        }catch{
            print(error)
        }
        
       let r = Rijndael(key: llave.data(using: .utf8)!, mode: .cbc)!
        guard let cipherData = r.encrypt(data: cifrar.data(using: .utf8)!, blockSize: 16, iv: iv.data(using: .utf8)!) ?? nil else { return }
       
        print("cifrado Rijndael: \(Data(cipherData).base64EncodedString())")
        */
        
        /*do{
            let encrypted = try AES(key: bLlave, blockMode: CBC(iv: bIv), padding: .pkcs7).encrypt(bCifrar)
            print("cifrado AES: \(Data(encrypted).base64EncodedString())")
            
            let gcm = GCM(iv: bIv, mode: .detached)
            let key: [UInt8] = Array("SIAPMaguen200000".utf8) as [UInt8]
          let encrypted2 = try AES(key: key, blockMode: gcm, padding: .pkcs7).encrypt(bCifrar)
            
            print("cifrado AES-GCM: \(Data(encrypted2).base64EncodedString())")
            
            let k = "SIAPMaguen20"
            
            let aes = try AES(key: k, iv: iv)
            let ciphertext = try aes.encrypt(Array(cifrar.utf8))
            print("cifrado AES 2: \(Data(ciphertext).base64EncodedString())")
            
        }catch {
            print(error)
        }*/
        
       
        
        
            
        if(ConexionRed.isConnectedToNetwork()){
            let imageURL = URL(string: fotoUrl.replacingOccurrences(of: " ", with: "%20"))!
              Alamofire.request(imageURL).responseJSON {
              response in

              let status = response.response?.statusCode
                if(status!>200){
                    let imagen = self.generarQR(from: cifrado)
                    let imageURL = URL(string: self.urlFotos+"sinfoto.png")!
                    self.imgFotoPadre.cargar(url: imageURL)
                    self.qrImage.image = imagen
                    UserDefaults.standard.set(self.urlFotos+"sinfoto.png", forKey: "urlfotoQR")
                }else{
                    let imagen = self.generarQR(from: cifrado)
                    let imageURL = URL(string: fotoUrl.replacingOccurrences(of: " ", with: "%20"))
                    print("foto: \(fotoUrl)")
                    let placeholderImageURL = URL(string: self.urlFotos+"sinfoto.png")!
                    self.imgFotoPadre.cargar(url: imageURL!)
                    self.qrImage.image = imagen
                }

            }
         }else{
            let imagen = self.generarQR(from: fotoUrl)
            self.qrImage.image = imagen
        }
        
        
        
         /*if(ConexionRed.isConnectedToNetwork()){
            let imageURL = URL(string: fotoUrl)!
              Alamofire.request(imageURL).responseJSON {
              response in

              let status = response.response?.statusCode
                if(status!>200){
                    let imagen = self.generarQR(from: self.urlFotos+"sinfoto.png")
                    let imageURL = URL(string: self.urlFotos+"sinfoto.png")!
                    self.imgFotoPadre.sd_setImage(with: imageURL)
                    self.qrImage.image = imagen
                    UserDefaults.standard.set(self.urlFotos+"sinfoto.png", forKey: "urlfotoQR")
                }else{
                    let imagen = self.generarQR(from: fotoUrl)
                    let imageURL = URL(string: fotoUrl)!
                    let placeholderImageURL = URL(string: self.urlFotos+"sinfoto.png")!
                    self.imgFotoPadre.sd_setImage(with: imageURL,placeholderImage:UIImage.init(named: "sinfoto.png"))
                    self.qrImage.image = imagen
                }

            }
         }else{
            let imagen = self.generarQR(from: fotoUrl)
            self.qrImage.image = imagen
        }*/
        
        
       
       
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
    
    
    
  

   

}
