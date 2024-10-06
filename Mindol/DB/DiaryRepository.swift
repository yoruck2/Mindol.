//
//  DiaryViewModel.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import Foundation
import RealmSwift
//import Combine

class DiaryRepository: ObservableObject {
    static let shared = DiaryRepository()
    @ObservedResults(DiaryTable.self)
    var diaryList
    
    let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
    }
    
    func createDiary(_ diary: DiaryTable) {
        $diaryList.append(diary)
//        do {
//            try realm.write {
//                realm.add(diary, update: .modified)
//            }
//        } catch {
//            print("Error creating diary: \(error)")
//        }
    }
    
    func updateDiary(_ diary: DiaryTable) {
        do {
            try realm.write {
                realm.add(diary, update: .modified)
            }
        } catch {
            print("Error updating diary: \(error)")
        }
    }
    
    func deleteDiary(_ diary: DiaryTable) {
        $diaryList.remove(diary)
    }
}

extension DiaryRepository {
    
    func hasDiaryForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        return diaryList.filter(predicate).count > 0
    }
    
    func getDiariesForCurrentMonth(date: Date) -> [DiaryTable] {
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return Array(diaryList.filter("date BETWEEN {%@, %@}", startOfMonth, endOfMonth))
    }
    
    // 아이디로 일기 찾기
    func getDiary(by id: ObjectId) -> DiaryTable? {
        return realm.object(ofType: DiaryTable.self, forPrimaryKey: id)
    }
    // day로 일기 찾기 (
    func getDiaryForDate(_ date: Date) -> DiaryTable? {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            return diaryList.filter("date >= %@ AND date < %@", startOfDay, endOfDay).first
        }
    
}
