//
//  Repository.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import Foundation
import RealmSwift
import Combine

protocol DiaryRepository {
    func create(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
    func read(id: ObjectId) -> AnyPublisher<DiaryTable?, Error>
    func update(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
    func delete(_ diary: DiaryTable) -> AnyPublisher<Void, Error>
    func getAll() -> AnyPublisher<[DiaryTable], Error>
}

class RealmDiaryRepository: DiaryRepository {
    private let realm: Realm
    init() {
        self.realm = try! Realm()
        print(realm.configuration.fileURL ?? "")
    }
    
    func create(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.realm.write {
                    self.realm.add(diary)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func read(id: ObjectId) -> AnyPublisher<DiaryTable?, Error> {
        return Just(realm.object(ofType: DiaryTable.self, forPrimaryKey: id))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func update(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.realm.write {
                    self.realm.add(diary, update: .modified)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(_ diary: DiaryTable) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.realm.write {
                    self.realm.delete(diary)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getAll() -> AnyPublisher<[DiaryTable], Error> {
        return Just(Array(realm.objects(DiaryTable.self)))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
