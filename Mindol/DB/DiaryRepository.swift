//
//  DiaryViewModel.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import Foundation
import RealmSwift
import Combine

class DiaryRepository: ObservableObject {
    static let shared = DiaryRepository()
    let realm = try! Realm()
    @ObservedResults(DiaryTable.self)
    var diaryList
//    @Published var diaries: [DiaryTable] = []
    
    private init() {
        print(realm.configuration.fileURL ?? "")
    }
    
//    func fetchDiaries() {
//        diaryTable = realm.objects(DiaryTable.self)
//    }
    
    func createDiary(_ diary: DiaryTable) {
        do {
            try realm.write {
                realm.add(diary, update: .modified)
            }
//            fetchDiaries()
        } catch {
            print("Error creating diary: \(error)")
        }
    }
    
    func updateDiary(_ diary: DiaryTable) {
        do {
            try realm.write {
                realm.add(diary, update: .modified)
            }
//            fetchDiaries()
        } catch {
            print("Error updating diary: \(error)")
        }
    }
    
    func deleteDiary(_ diary: DiaryTable) {
        do {
            try realm.write {
                if let diaryToDelete = realm.object(ofType: DiaryTable.self, forPrimaryKey: diary.id) {
                    realm.delete(diaryToDelete)
                }
            }
//            fetchDiaries()
        } catch {
            print("Error deleting diary: \(error)")
        }
    }
}
