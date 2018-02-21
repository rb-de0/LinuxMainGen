import FileSmith
import Foundation
import SourceKittenFramework

final class SourceWriter {
    
    static let space = " "
    static let comma = ","
    static let newLine = "\n"
    
    static var indent: String {
        return String(repeating: space, count: 4)
    }
    
    class func multiline(_ text: String, indentSize: Int) -> String {
        
        return text.lines()
            .enumerated()
            .map { (offset, text) -> String in offset == 0 ? text : String(repeating: indent, count: indentSize) + text }
            .joined(separator: newLine)
    }
    
    class func writeAllTestsExtension(testClasses: [TestClass]) throws {
        
        for testClass in testClasses {
            
            guard let path = testClass.file.path else {
                continue
            }
            
            var contents = testClass.file.contents
            let structure = try Structure(file: testClass.file)

            if let ext = structure.extension(), ext.isAllTestsExtension, ext.name == testClass.name {
                
                guard let offset = ext.offset, let length = ext.length else {
                    continue
                }
                
                if let range = testClass.file.contents.ns.byteRangeToNSRange(start: offset, length: length) {
                    contents = testClass.file.contents.ns.replacingCharacters(in: range, with: "")
                    let file = try FileSmith.WritableFile(open: path)
                    file.overwrite(contents)
                }
            }
            
            let newLineDroped = contents.dropLast(while: { $0 == "\n" })
            
            let count = testClass.testCases.count
            let testCaseCode = testClass.testCases.enumerated()
                .map { (offset, testCase) -> String in
                    let lastCharacter = offset == count - 1 ? "" : comma
                    return "(\"\(testCase)\", \(testCase))" + lastCharacter
                }
                .joined(separator: newLine)
            
            let extensionCode = """
            extension \(testClass.name) {
                public static let allTests = [
                    \(multiline(testCaseCode, indentSize: 2))
                ]
            }
            """
            
            let file = try FileSmith.WritableFile(open: path)
            file.overwrite(newLineDroped.appending(newLine.repeated(2)) + extensionCode)
        }
    }
    
    class func writeLinuxMain(testClasses: [TestClass], in testDirectories: [DirectoryPath]) throws {
        
        let linuxMainPath = FilePath("Tests/LinuxMain.swift")
        let linuxMainEdit = try linuxMainPath.create(ifExists: .replace)
        
        let count = testClasses.count
        let testListCode = testClasses.enumerated()
            .map { (offset, textCase) -> String in
                let lastCharacter = offset == count - 1 ? "" : comma
                return "testCase(\(textCase.name).allTests)" + lastCharacter
            }
            .joined(separator: newLine)
        
        let testableImportCode = testDirectories
            .map { "@testable import" + space + $0.name }
            .joined(separator: newLine)
        
        let tests = """
        let tests: [XCTestCaseEntry] = [
            \(multiline(testListCode, indentSize: 1))
        ]
        """
        
        linuxMainEdit.print("import XCTest")
        linuxMainEdit.print()
        linuxMainEdit.print(testableImportCode)
        linuxMainEdit.print()
        linuxMainEdit.print(tests)
        linuxMainEdit.print()
        linuxMainEdit.print("XCTMain(tests)")
    }
}
