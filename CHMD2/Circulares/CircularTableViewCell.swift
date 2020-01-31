//
//  CircularTableViewCell.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/23/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit

class CircularTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCircular: UIImageView!
    @IBOutlet weak var lblEncabezado: UILabel!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    var favMetodo:String="favCircular.php"
    var delMetodo:String="eliminarCircular.php"
    var urlBase:String="https://www.chmd.edu.mx/WebAdminCirculares/ws/"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.accessoryType = selected ? .checkmark : .none
        self.accessoryType = selected ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
}
