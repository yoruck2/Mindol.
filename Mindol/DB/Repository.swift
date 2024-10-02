//
//  Repository.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import Foundation
import RealmSwift
import Combine

//protocol DiaryRepository {
//    func create(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
//    func read(id: ObjectId) -> AnyPublisher<DiaryTable?, Error>
//    func update(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
//    func delete(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
//    func getAll() -> AnyPublisher<[DiaryTable], Error>
//}

//class RealmDiaryRepository: ObservableObject {
//    private let realm: Realm
//    
//    init() {
//        self.realm = try! Realm()
//        print(realm.configuration.fileURL ?? "")
//    }
//    
//    func create(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
//        return Future { promise in
//            do {
//                try self.realm.write {
//                    self.realm.add(diary)
//                }
//                promise(.success(()))
//            } catch {
//                promise(.failure(error))
//            }
//        }.eraseToAnyPublisher()
//    }
//    
//    func read(id: ObjectId) -> AnyPublisher<DiaryTable?, Error> {
//        return Future { promise in
//            let diary = self.realm.object(ofType: DiaryTable.self, forPrimaryKey: id)
//            promise(.success(diary))
//        }.eraseToAnyPublisher()
//    }
//    
//    func update(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
//        return Future { promise in
//            do {
//                try self.realm.write {
//                    self.realm.add(diary, update: .modified)
//                }
//                promise(.success(()))
//            } catch {
//                promise(.failure(error))
//            }
//        }.eraseToAnyPublisher()
//    }
//    
//    func delete(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
//        return Future { promise in
//            guard let diaryToDelete = self.realm.object(ofType: DiaryTable.self, forPrimaryKey: diary.id) else {
//                promise(.failure(NSError(domain: "DiaryRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Diary not found"])))
//                return
//            }
//            
//            do {
//                try self.realm.write {
//                    self.realm.delete(diaryToDelete)
//                }
//                promise(.success(()))
//            } catch {
//                promise(.failure(error))
//            }
//        }.eraseToAnyPublisher()
//    }
//    
//    func getAll() -> AnyPublisher<[DiaryTable], Error> {
//        return Future { promise in
//            let diaries = Array(self.realm.objects(DiaryTable.self))
//            promise(.success(diaries))
//        }.eraseToAnyPublisher()
//    }
//}
