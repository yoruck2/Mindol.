//
//  DiaryTable.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import RealmSwift
import Foundation


final class DiaryTable: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var feeling: String
    @Persisted var date: Date
    @Persisted var contents: Contents?
    
    convenience init(feeling: String, date: Date, contents: Contents) {
        self.init()
        self.feeling = feeling
        self.date = date
        self.contents = contents
    }
}

class Contents: EmbeddedObject {
    @Persisted var text: String?
    @Persisted var photo: String?
}

extension ObjectId: Identifiable {}
