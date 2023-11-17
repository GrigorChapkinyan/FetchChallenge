//
//  BaseStorageConnectedViewModel.swift
//  FetchChallenge
//
//  Created by Grigor Chapkinyan on 11/16/23.
//

import Foundation
import Combine

class BaseStorageConnectedViewModel<LocalType: IModelManagedObject, RemoteType: IModelStructObject>: ObservableObject where LocalType.PredicateKeys == RemoteType.PredicateKeys {
    // MARK: - Input
    
    var refreshOnAppear: (() -> ())?
    var refreshOnPull: (() -> ())?

    // MARK: - Input-Output
    
    @Published var presentAlert: Bool = false {
        didSet {
            if presentAlert == false {
                error = nil
            }
        }
    }
    
    // MARK: - Output
    
    @Published private(set) var isFetchingFirstData: Bool = true
    @Published private(set) var isLoadingSomething: Bool = false
    @Published private(set) var error: Error? {
        didSet {
            if let _ = error {
                if userActionWasTriggered {
                    presentAlert = true
                }
                
                userActionWasTriggered = false
            }
        }
    }
    
    // MARK: - Public Properties
    
    var fetchResultBlock: (([RemoteType]?) -> Void)?
    var fetchLimit: Int?
    var sortDescriptor: SortDescriptor<RemoteType>?
    var predicateDict: [RemoteType.PredicateKeys : String]?
    var userActionWasTriggered: Bool = false

    // MARK: - Private Properties
    
    private var refresh: (() -> ())?
    private let inMemoryLocalStorage: Bool
    private var cancalables = [AnyCancellable]()
    private var storageManager: BaseStorageManager<BaseLocalStorage<LocalType, RemoteType>, BaseRemoteStorage<RemoteType>>! {
        didSet {
            setupStorageManagerBindings()
        }
    }
    
    // MARK: - Initializers
    
    init(
        inMemoryLocalStorage: Bool = false
    ) {
        self.inMemoryLocalStorage = inMemoryLocalStorage
        setupInitialBindings()
    }
    
    deinit {
        cancalables.forEach({ $0.cancel() })
    }
    
    // MARK: - Private API
    
    private func setupInitialBindings() {
        refresh = { [weak self] in
            Task.detached { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                // Setting manager if it is nil
                if strongSelf.storageManager == nil {
                    strongSelf.storageManager = await BaseStorageManager.getConstructedWithBaseObjects(localStorageInMemory: strongSelf.inMemoryLocalStorage)
                }
                                
                await strongSelf.storageManager.getItems(predicateDict: strongSelf.predicateDict, sortDescriptor: strongSelf.sortDescriptor, limit: strongSelf.fetchLimit)
            }
        }
        
        refreshOnAppear = { [weak self] in
            self?.userActionWasTriggered = false
            self?.refresh?()
        }
        
        refreshOnPull = { [weak self] in
            self?.userActionWasTriggered = true
            self?.refresh?()
        }
    }
    
    private func setupStorageManagerBindings() {
        cancalables.forEach({ $0.cancel() })
        
        cancalables.append(storageManager
            .$isFetchingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (val) in
                self?.isLoadingSomething = val
            })
        
        cancalables.append(storageManager
            .$lastError
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (val) in
                self?.error = val
                self?.isFetchingFirstData = false
            })
        
        cancalables.append(storageManager
            .$lastSuccessfulFetchResult
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (items) in
                defer {
                    self?.isFetchingFirstData = false
                }
                
                self?.userActionWasTriggered = false
                self?.fetchResultBlock?(items)
            }))
    }
}
