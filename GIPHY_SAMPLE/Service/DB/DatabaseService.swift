//
//  DatabaseService.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import RealmSwift

class DatabaseService {
    private lazy var realm = try! Realm()
    
    private  func saveRealmObject<T: Object>(item: T, update: Realm.UpdatePolicy) {
        do {
            try self.realm.write {
                self.realm.add(item, update: update)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// 타입 지정하여 저장된 Object 반환
    private func getRealmObject(_ type: Object.Type) -> Results<Object>? {
        return self.realm.objects(type)
    }
    
    func getFavoriteList() -> [GifObject] {
        var recentList: [GifObject] = []
        if let objects = self.getRealmObject(DB_Gif_Object.self)?.sorted(byKeyPath: "id", ascending: false) {
            for i in 0..<objects.count {
                if let recent = objects[i] as? DB_Gif_Object {
                    let thumbnail = Thumbnail(width: recent.thumbnail_width, height: recent.thumbnail_height, url: recent.thumbnail_url)
                    let original = Original(width: recent.original_width, height: recent.original_height, url: recent.original_url)
                    
                    let gifObj = GifObject(id: recent.id, images: Images(original: original, preview_gif: thumbnail))
                    
                    recentList.append(gifObj)
                }
            }
        }
        
        return recentList
    }
    
    func findFavoriteItem(id: String?) -> Bool {
        guard let id = id else { return false }
       
       if (getRealmObject(DB_Gif_Object.self)?.filter("id == %@", id).first) != nil {
            return true
        }
        return false
    }
    
    func deleteFavoriteItem(id: String?) {
       guard let id = id else { return }
       if let item = getRealmObject(DB_Gif_Object.self)?.filter("id == %@", id).first {
          do {
             try self.realm.write {
                self.realm.delete(item)
             }
          } catch let error {
             print("error : \(error.localizedDescription)")
          }
       }
    }
    
   func addFavoriteList(obj: GifObject?) {
      guard let obj = obj else { return }
      
      let addItem = DB_Gif_Object()
      addItem.id = obj.id ?? ""
      addItem.original_width = obj.images?.original?.width ?? ""
      addItem.original_height = obj.images?.original?.height ?? ""
      addItem.original_url = obj.images?.original?.url ?? ""
      addItem.thumbnail_width = obj.images?.preview_gif?.width ?? ""
      addItem.thumbnail_height = obj.images?.preview_gif?.height ?? ""
      addItem.thumbnail_url = obj.images?.preview_gif?.url ?? ""
      
      if (getRealmObject(DB_Gif_Object.self)?.filter("id == %@", addItem.id).first) != nil {
         saveRealmObject(item: addItem, update: .modified)
      } else {
         saveRealmObject(item: addItem, update: .all)
      }
   }
}
 
class DB_Gif_Object: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var original_width: String = ""
    @objc dynamic var original_height: String = ""
    @objc dynamic var original_url: String = ""
    
    @objc dynamic var thumbnail_width: String = ""
    @objc dynamic var thumbnail_height: String = ""
    @objc dynamic var thumbnail_url: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
 
