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
//    let realm = try! Realm()
    @ObservedResults(DiaryTable.self)
    var diaryList
//    @Published var diaries: [DiaryTable] = []
    
    let realm: Realm
        
        init(realm: Realm = try! Realm()) {
            self.realm = realm
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

extension DiaryRepository {
    
    func hasDiaryForDate(_ date: Date) -> Bool {
        let realm = try! Realm()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        return realm.objects(DiaryTable.self).filter(predicate).count > 0
    }
    
    func getDiariesForCurrentMonth(date: Date) -> [DiaryTable] {
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return Array(diaryList.filter("date BETWEEN {%@, %@}", startOfMonth, endOfMonth))
    }
    
    
    func getDiary(by id: ObjectId) -> DiaryTable? {
        return realm.object(ofType: DiaryTable.self, forPrimaryKey: id)
    }
    
}
