import Foundation
import SourceKittenFramework

final class SourceParser {
    
    static let xcTestCaseClass = "XCTestCase"

    class func parentClassForTests(files: [File]) throws -> [String] {
        
        func classes(parentClass: String) throws -> [String] {
            
            var result = [String]()
            
            for file in files {
                let structure = try Structure(file: file)
                if let classInFile = structure.class(parentClasses: [parentClass]), let className = classInFile.name, !classInFile.isFinalClass {
                    result.append(className)
                }
            }
            
            guard result.isEmpty else {
                let nestedResult = try result + result.flatMap { try classes(parentClass: $0) }
                return Set(nestedResult).array
            }
            
            return Set(result).array
        }
        
       return try classes(parentClass: xcTestCaseClass) + [xcTestCaseClass]
    }

    class func parse(files: [File], testCaseParentClasses: [String]) throws -> [TestClass] {
        
        var testClasses = [TestClass]()
        
        for file in files {
            let structure = try Structure(file: file)
            let scopes = structure.scopes(parentClasses: testCaseParentClasses)
            if let className = scopes.first?.name {
                testClasses.append(TestClass(file: file, name: className, testCases: scopes.flatMap { $0.testCases() }))
            }
        }
        
        return testClasses.filter { !$0.testCases.isEmpty }
    }
}
