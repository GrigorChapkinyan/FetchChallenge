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
    
    func test_BaseStorageManager_GetItemsMethod_MealCategoryData_WithSuccess() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let categoryStorageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)

        var meal: Meal?
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.id : "1"],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
            
            meal = category?
                .meals?
                .first
        }
        catch {
            receivedError = error
        }
        
        // MARK: Checking category
        
        XCTAssertEqual(category?.id, "1")
        XCTAssertEqual(category?.name, "Beef")
        XCTAssertEqual(category?.thumbUrlPath, "https://www.themealdb.com/images/category/beef.png")
        XCTAssertEqual(category?.descriptionStr, "Beef is the culinary name for meat from cattle, particularly skeletal muscle. Humans have been eating beef since prehistoric times.[1] Beef is a source of high-quality protein and essential nutrients.[2]")

        // MARK: Checking meal
        
        XCTAssertNil(meal)
        
        // MARK: Checking error

        XCTAssertNil(receivedError)
    }

    func test_BaseStorageManager_GetItemsMethod_WithFailure_DataDowncastError() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.returnWrongDataType])
        let categoryStorageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.id : "1"],
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
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.returnInvalidFileUrl])
        let categoryStorageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.id : "1"],
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
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory, mockScenes: [.triggerConnectionError])
        let categoryStorageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var category: MealCategory?
        var receivedError: Error?

        do {
            category = try await categoryStorageManager.getItems(
                predicateDict: [.id : "1"],
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
        typealias localType = MealMO
        typealias remoteType = Meal
        
        // First fetching without connection error,
        // To save "inMemory" storage
        let mealId = "53049"
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .meals(type: .byCategoryName))
        let storageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var receivedError: Error?

        do {
            let _ = try await storageManager.getItems(
                predicateDict: [.id : mealId],
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
        XCTAssertNil(storageManager.lastError)

        // Adding "noInternet" mock scene to test executor
        mockHttpExecutor.mockScenes = [.triggerConnectionError]
        
        var meal: Meal?

        do {
            meal = try await storageManager.getItems(
                predicateDict: [.id : mealId],
                sortDescriptor: SortDescriptor(\.id, order: .forward),
                limit: 10)
                .get()
                .first
        }
        catch {
            receivedError = error
        }

        // MARK: Checking category

        XCTAssertEqual(meal?.id, "53049")
        XCTAssertEqual(meal?.name, "Apam balik")
        XCTAssertEqual(meal?.thumUrlPath, "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg")
        
        // MARK: Checking error

        XCTAssertNil(receivedError)
        XCTAssertTrue((storageManager.lastError as? URLError)?.code == .notConnectedToInternet)
    }
    
    func test_BaseStorageManager_addItemsMethod() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let storageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var receivedError: Error?

        do {
            try await storageManager.add([
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
    
    func test_BaseStorageManager_removeItemsMethod() async throws {
        typealias localType = MealCategoryMO
        typealias remoteType = MealCategory
        
        let mockHttpExecutor = TestRequestExecutor(dataModelType: .mealCategory)
        let storageManager: BaseStorageManager<BaseLocalStorage<localType, remoteType>, BaseRemoteStorage<remoteType>> = await BaseStorageManager.getConstructedWithBaseObjects(networkExecutor: mockHttpExecutor, localStorageInMemory: true)
        
        var receivedError: Error?

        do {
            try await storageManager.remove([
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
        
        var receivedError: Error?

        do {
            let categoryMOToAdd = try getTestMealCategory()
                .getManagedObject(context: await persistentContainer.moc) as! MealCategoryMO
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
        var receivedError: Error?
        var categoryMOToAddAndRemove: MealCategoryMO!
        
        do {
            categoryMOToAddAndRemove = try getTestMealCategory()
                .getManagedObject(context: await persistentContainer.moc) as? MealCategoryMO
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
        return MealCategory(
            id: "TestId",
            name: "TestName",
            thumbUrlPath: "TestUrlPath",
            categoryDescription: "TestDescription",
            meals: [
                Meal(
                    id: "TestId",
                    metadata: nil,
                    name: "TestName",
                    thumUrlPath: "TestUrlPath",
                    categoryName: nil
                )
            ]
        )
    }
}

// MARK: - DataModelType

fileprivate enum DataModelType {
    case mealCategory
    case meals(type: MealsDataFetchedType)
    
    enum MealsDataFetchedType {
        case byCategoryName
        case byId
    }
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
            
            case .meals(let mealType):
                switch mealType {
                    case .byId:
                        // Checking which file must be returned
                        let fileName = mockScenes.contains(.returnInvalidFileUrl) ? Constants.FetchChallenge.Utils.MockMealByIdInvalid.rawValue : Constants.FetchChallenge.Utils.mockMealByIdValid.rawValue
                        filePath = bundle.path(forResource: fileName, ofType: Constants.FetchChallenge.Utils.mockMealCategoryFileExt.rawValue)

                    case .byCategoryName:
                        // Checking which file must be returned
                        let fileName = mockScenes.contains(.returnInvalidFileUrl) ? Constants.FetchChallenge.Utils.mockMealByCategoryNameInvalid.rawValue : Constants.FetchChallenge.Utils.mockMealByCategoryNameValid.rawValue
                        filePath = bundle.path(forResource: fileName, ofType: Constants.FetchChallenge.Utils.mockMealCategoryFileExt.rawValue)
                }
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
            
            case mockMealByIdValid = "MockMealByIdValid"
            case MockMealByIdInvalid = "MockMealByIdInvalid"
            
            case mockMealByCategoryNameValid = "MockMealByCategoryNameValid"
            case mockMealByCategoryNameInvalid = "MockMealByCategoryNameInvalid"
            
            case mockMealCategoryFileExt = "json"
        }
    }
}
