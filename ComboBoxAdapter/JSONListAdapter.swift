
//  Created by Alisher on 23.02.2023.
//

import SwiftyJSON

class JSONListAdapter {
    var idKey:[JSONSubscriptType] = ["#id"]
    var selectedChanged: (() -> ()) = {}
    var items: [JSON] = []
    var selected: JSON?
    
    init(items: [JSON], idKey: [JSONSubscriptType]) {
        self.idKey = idKey
        self.items = items
    }
    
    func setSelected(id:String) {
        selected = nil
        for item in self.items {
            if item[idKey].rawString() == id {
                selected = item
                break
            }
        }
        self.selectedChanged()
    }
    
    func selectFirst() {
        selected = self.items.first
        self.selectedChanged()
    }
    
    func getSelectedID() -> String? {
        if let id = selected?[idKey].rawString() {
            return id
        }
        return nil
    }
    
    func unSelect() {
        selected = nil
        self.selectedChanged()
    }
    
    func adapterClear() {
        items = []
        selected = nil
        self.selectedChanged()
    }
    
    func showSimpleActionSheet(vc:UIViewController, title: String? = nil, itemTitleKey: [JSONSubscriptType], itemDescKey: [JSONSubscriptType]? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for item in self.items {
            alert.addAction(UIAlertAction(title: item[itemTitleKey].stringValue, style: .default, handler: { action in
                self.selected = item
                self.selectedChanged()
            }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        vc.present(alert, animated: true)
        
    }
}

//let json = JSON(parseJSON: #"[{"id":1,"title":"Title1"},{"id":2,"title":"Title2"},{"id":3,"title":"Title3"}]"#)
//let adap = JSONListAdapter(items: json.arrayValue, idKey: ["id"])
//adap.selectedChanged = {
//    print(adap.getSelectedID() ?? "-1")
//}
//adap.setSelected(id: "2")
//adap.showSimpleActionSheet(vc: self, title: "Hello", itemTitleKey: ["title"])













































// ------------------------------------------------------------------------------------
class UniversalListAdapter<Element> {
    var overideGetItemID: ((Element)->String?) = {el in return nil}
    var selectedChanged: (()->()) = {}
    var items: [Element] = []
    var selected: Element?
    
    
    init(){}
    
    init(items:[Element], getItemID: @escaping ((Element)->String?) = {el in return nil}) {
        self.items = items
        self.overideGetItemID = getItemID
    }
    
    func setSelected(id:String){
        selected = nil
        for item in self.items {
            if overideGetItemID(item) == id {
                selected = item
                break
            }
        }
        self.selectedChanged()
    }
    
    func selectFirst(){
        selected = self.items.first
        self.selectedChanged()
    }
    
    func getSelectedID() -> String?{
        if let selected = selected{
            return overideGetItemID(selected)
        }
        return nil
    }
    
    func unSelect(){
        selected = nil
        self.selectedChanged()
    }
    
    func adapterClear(){
        items = []
        selected = nil
        self.selectedChanged()
    }
}
//---------------------------------------------------------------------------------------

//var arr:[[String:String]] = []
//for i in 0..<5 {
//    var item = [String:String]()
//    item["id"] = "\(i)"
//    item["title"] = "title\(i)"
//    arr.append(item)
//}
//
//let ad = UniversalListAdapter<JSON>()
//ad.items = [JSON("")]
//let adapter = UniversalListAdapter(items: arr) { item in
//    return item["id"]
//}
//adapter.selectedChanged = {
//    print(adapter.getSelectedID() ?? "null")
//}
//adapter.setSelected(id: "3")
//
//
//
//let s = AlertListSheetVC(title: "Выбрать",adapter: adapter) { item in
//    return item["title"] ?? "Unknown"
//}
//s.showForSelect(vc: self)















// ---------------------------------------------------------------------------------------
class AlertListSheetVC<Element> {
    let adapter:UniversalListAdapter<Element>
    var overideGetTitle: ((Element)->String)
    var title:String?
    
    init(title:String? = nil, adapter:UniversalListAdapter<Element>,overideGetTitle: @escaping ((Element)->String) = {el in return "NotSetTitle"}) {
        self.adapter = adapter
        self.overideGetTitle = overideGetTitle
        self.title = title
    }
    func showForSelect(vc:UIViewController){
        let alert = UIAlertController(title: self.title, message: nil, preferredStyle: .actionSheet)
        for item in adapter.items {
            alert.addAction(UIAlertAction(title: overideGetTitle(item), style: .default,handler: { action in
                self.adapter.selected = item
                self.adapter.selectedChanged()
            }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        vc.present(alert, animated: true)
    }
}

extension UniversalListAdapter {
    func showSimpleActionSheet(vc: UIViewController,title:String? = nil, overideGetTitle: @escaping ((Element)->String) = {el in return "NotSetTitle"}){
        let s = AlertListSheetVC(title: "Выбрать",adapter: self,overideGetTitle: overideGetTitle)
        s.showForSelect(vc: vc)
    }
}
// ---------------------------------------------------------------------------------------
