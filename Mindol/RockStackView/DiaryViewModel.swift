//
//  DiaryViewModel.swift
//  Mindol
//
//  Created by dopamint on 9/29/24.
//

import Foundation
import RealmSwift
import Combine

class DiaryViewModel: ObservableObject {
    private let repository: DiaryRepository
    @Published var diaries: [DiaryTable] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: DiaryRepository? = nil) {
        do {
            self.repository = try repository ?? RealmDiaryRepository()
        } catch {
            fatalError("Failed to initialize repository: \(error)")
        }
        fetchDiaries()
    }
    
    func fetchDiaries() {
        repository.getAll()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching diaries: \(error)")
                }
            }, receiveValue: { [weak self] diaries in
                self?.diaries = diaries
            })
            .store(in: &cancellables)
    }
    
    func createDiary(_ diary: DiaryTable) {
        repository.create(diary)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error creating diary: \(error)")
                } else {
                    self?.fetchDiaries()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func updateDiary(_ diary: DiaryTable) {
        repository.update(diary)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error updating diary: \(error)")
                } else {
                    self?.fetchDiaries()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func deleteDiary(_ diary: DiaryTable) {
        repository.delete(diary)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error deleting diary: \(error)")
                } else {
                    self?.fetchDiaries()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
