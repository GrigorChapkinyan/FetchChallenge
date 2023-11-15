//
//  FetchChallengeTests.swift
//  FetchChallengeTests
//
//  Created by Grigor Chapkinyan on 11/9/23.
//

import XCTest
@testable import FetchChallenge

final class FetchChallengeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - BaseStorageManager
    
    func test_BaseStorageManager_GetItemsMethod_WithSuccess() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryTestName = "CategoryTestName"
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)

        var meal: Meal?
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
            
            meal = category?
                .meals
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category
        XCTAssertEqual(category?.id, categoryTestName)
        XCTAssertEqual(category?.name, categoryTestName)
        XCTAssertEqual(category?.meals.count, 1)

        // MARK: Checking meal
        
        XCTAssertNil(meal?.metadata)
        XCTAssertEqual(meal?.id, "53049")
        XCTAssertEqual(meal?.name, "Apam balik")
        XCTAssertEqual(meal?.thumUrlPath, "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")
        
        // MARK: Checking error

        XCTAssertNil(receivedError)
    }

    func test_BaseStorageManager_GetItemsMethod_WithFailure_DataDowncastError() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryTestName = "CategoryTestName"
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.returnWrongDataType])
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)

        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category
        XCTAssertNil(category)

        // MARK: Checking error

        XCTAssertEqual(receivedError as? BaseRemoteStorageRequestExecutorError, BaseRemoteStorageRequestExecutorError.dataDowncastError)
        XCTAssertEqual(receivedError?.localizedDescription, BaseRemoteStorageRequestExecutorError.dataDowncastError.localizedDescription)
    }
    
    func test_BaseStorageManager_GetItemsMethod_WithFailure_DecodeError() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryTestName = "CategoryTestName"
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.returnInvalidFileUrl])
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)

        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category
        XCTAssertNil(category)

        // MARK: Checking error

        XCTAssertTrue(receivedError is DecodingError)
    }
    
    func test_BaseStorageManager_GetItemsMethod_WithFailure_NoConnection_NoDataReturn() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryTestName = "CategoryTestName"
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.triggerConnectionError])
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)
        
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category
        XCTAssertNil(category)

        // MARK: Checking error

        XCTAssertNil(receivedError)
        XCTAssertTrue((categoryStorageManager.lastError as? URLError)?.code == .notConnectedToInternet)
    }
    
    func test_BaseStorageManager_GetItemsMethod_WithFailure_NoConnection_DataReturn() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryTestName = "CategoryTestName"
        // First fetching without connection error,
        // To save "inMemory" storage
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)
        
        var receivedError: Error?

        do {
            let _ = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
        }
        catch {
            receivedError = error
        }
        
        // Double-checking errors to be nil
        XCTAssertNil(receivedError)
        XCTAssertNil(categoryStorageManager.lastError)

        // Adding "noInternet" mock scene to test executor
        mockHttpExecutor.mockScenes = [.triggerConnectionError]
        
        var meal: Meal?
        var category: MealCategory?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.name : categoryTestName],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
            
            meal = category?
                .meals
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category
        XCTAssertEqual(category?.id, categoryTestName)
        XCTAssertEqual(category?.name, categoryTestName)
        XCTAssertEqual(category?.meals.count, 1)

        // MARK: Checking meal
        
        XCTAssertNil(meal?.metadata)
        XCTAssertEqual(meal?.id, "53049")
        XCTAssertEqual(meal?.name, "Apam balik")
        XCTAssertEqual(meal?.thumUrlPath, "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")


        // MARK: Checking error

        XCTAssertNil(receivedError)
        XCTAssertTrue((categoryStorageManager.lastError as? URLError)?.code == .notConnectedToInternet)
    }
    
    func test_BaseStorageManager_addItemsMethod() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)
        
        var receivedError: Error?

        do {
            try await categoryStorageManager.add([
                MealCategory(id: "TestId", name: "TestName", meals: [
                    Meal(id: "TestId", metadata: nil, name: "TestName", thumUrlPath: "TestUrlPath")
                ])
            ])
            .get()
        }
        catch {
            receivedError = error
        }

        // MARK: Checking error

        XCTAssertTrue((receivedError as? BaseRemoteStorageRequestExecutorError) == BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction)
    }
    
    func test_BaseStorageManager_removeItemsMethod() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let categoryRemoteStorageExecutor = BaseRemoteStorageRequestExecutor<remoteType>(with: mockHttpExecutor)
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let categoryRemoteStorage = BaseRemoteStorage<remoteType>(with: categoryRemoteStorageExecutor)
        let categoryStorageManager = BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage>(localStorage: categoryLocalStorage, remoteStorage: categoryRemoteStorage)
        
        var receivedError: Error?

        do {
            try await categoryStorageManager.remove([
                getTestMealCategory()
            ])
            .get()
        }
        catch {
            receivedError = error
        }

        // MARK: Checking error

        XCTAssertTrue((receivedError as? BaseRemoteStorageRequestExecutorError) == BaseRemoteStorageRequestExecutorError.noProvidedApiForCurrentAction)
    }
    
    // MARK: - BaseLocalStorage
    
    func test_BaseLocalStorage_AddMethod_WithSuccess() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let persistentContainer = await PersistentContainerProvider.shared.getItem(with: localType.getPersistentContainerName(), inMemory: true)
        let categoryMOToAdd = getTestMealCategory()
            .getManagedObject(context: await persistentContainer.moc) as! MealCategoryMO
        var receivedError: Error?

        do {
            try await categoryLocalStorage
                .add([categoryMOToAdd])
                .get()
        }
        catch {
            receivedError = error
        }

        XCTAssertNil(receivedError)
    }
    
    func test_BaseLocalStorage_RemoveMethod_WithSuccess() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let categoryLocalStorageExecutor = await BaseLocalStorageRequestExecutor<localType, remoteType>(inMemory: true)
        let categoryLocalStorage = BaseLocalStorage<localType, remoteType>(with: categoryLocalStorageExecutor)
        let persistentContainer = await PersistentContainerProvider.shared.getItem(with: localType.getPersistentContainerName(), inMemory: true)
        let categoryMOToAddAndRemove = getTestMealCategory()
            .getManagedObject(context: await persistentContainer.moc) as! MealCategoryMO
        var receivedError: Error?

        do {
            try await categoryLocalStorage
                .add([categoryMOToAddAndRemove])
                .get()
        }
        catch {
            receivedError = error
        }

        XCTAssertNil(receivedError)
        
        do {
            try await categoryLocalStorage
                .remove([categoryMOToAddAndRemove])
                .get()
        }
        catch {
            receivedError = error
        }

        XCTAssertNil(receivedError)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // MARK: - Private API
    
    private func getTestMealCategory() -> MealCategory {
        return MealCategory(id: "TestId", name: "TestName", meals: [
            Meal(id: "TestId", metadata: nil, name: "TestName", thumUrlPath: "TestUrlPath")
        ])
    }
}

// MARK: - DataModelType

fileprivate enum DataModelType {
    case mealCategory
}

// MARK: - TestRequestExecutor

fileprivate final class TestRequestExecutor: IRequestExecutor {
    // MARK: - Nested Types
    
    enum MockScenes {
        case returnWrongDataType
        case returnInvalidFileUrl
        case triggerConnectionError
    }
    
    enum TestRequestExecutorError: Swift.Error {
        case mockFileNotFound
    }
    
    // MARK: - Private Properties
    
    /// The type of the model with which the class will work
    private let dataModelType: DataModelType
    /// An array of mock scenes which must be produced
    var mockScenes: [MockScenes]

    // MARK: - Initializers

    init(
        dataModelType: DataModelType,
        mockScenes: [MockScenes] = []
        
    ) {
        self.dataModelType = dataModelType
        self.mockScenes = mockScenes
    }
    
    // MARK: - IRequestExecutor
    
    func execute(_ request: FetchChallenge.IRequest) async -> Result<Any, Error> {
        // If "mustReturnWrongDataType" is true, we need to return other data type than "Data", to trigger an specific error
        if mockScenes.contains(.returnWrongDataType) {
            return .success(Void())
        }
        else if mockScenes.contains(.triggerConnectionError) {
            return .failure(URLError(.notConnectedToInternet))
        }
        else {
            do {
                let data = try getMockDataFileAsData()
                return .success(data)
            }
            catch {
                return .failure(error)
            }
        }
    }
    
    // MARK: - Private API

    private func getMockDataFileAsData() throws -> Data {
        let mockDataFileUrl = try getMockDataFileUrl()
        let fileData = try Data(contentsOf: mockDataFileUrl)
        return fileData
    }
    
    private func getMockDataFileUrl() throws -> URL {
        // Getting file path from the current bundle
        let t = type(of: self)
        let bundle = Bundle(for: t.self)
        let filePath: String?
        
        switch self.dataModelType {
            case .mealCategory:
            // Checking which file must be returned
            let fileName = mockScenes.contains(.returnInvalidFileUrl) ? Constants.FetchChallenge.Utils.mockMealCategoryInvalidFileName.rawValue : Constants.FetchChallenge.Utils.mockMealCategoryValidFileName.rawValue
            filePath = bundle.path(forResource: fileName, ofType: Constants.FetchChallenge.Utils.mockMealCategoryFileExt.rawValue)
        }
        
        guard let filePath = filePath else {
            throw TestRequestExecutorError.mockFileNotFound
        }
        
        return URL(fileURLWithPath: filePath)
    }
}

// MARK: - Constants + upwards_ios_challengeTests

fileprivate extension Constants {
    struct FetchChallenge {
        enum Utils: String {
            case mockMealCategoryValidFileName = "MockMealCategoryValid"
            case mockMealCategoryInvalidFileName = "MockMealCategoryInvalid"
            case mockMealCategoryFileExt = "json"
        }
    }
}
