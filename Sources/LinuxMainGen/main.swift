import FileSmith
import Foundation
import Moderator
import SourceKittenFramework

let projectRootEnv = ProcessInfo.processInfo.environment["SWIFT_PROJECT_ROOT"]

let arguments = Moderator(description: "A tool to automatically generate LinuxMain.swift")
let projectRootPath = Argument<String?>
    .singleArgument(name: "directory", description: "The project root directory.")
    .default(projectRootEnv ?? "./")
    .map { (projectpath: String) in
        let projectdir = try Directory(open: projectpath)
        try projectdir.verifyContains("Tests")
        Directory.current = projectdir
    }

_ = arguments.add(projectRootPath)

do {
    try arguments.parse()
    
    // search
    let testDir = try Directory(open: "Tests")
    let files = testDir.files("*/*.swift", recursive: true)
    let testPackages = testDir.directories()
    
    // parse
    let sourceFiles = files.compactMap { SourceKittenFramework.File(path: $0.absoluteString) }
    let parentClasses = try SourceParser.parentClassForTests(files: sourceFiles)
    let testClasses = try SourceParser.parse(files: sourceFiles, testCaseParentClasses: parentClasses)
    
    // generate
    try SourceWriter.writeAllTestsExtension(testClasses: testClasses)
    try SourceWriter.writeLinuxMain(testClasses: testClasses, in: testPackages)
    
} catch {
    WritableFile.stderror.print(error)
    WritableFile.stderror.print()
    WritableFile.stderror.print(arguments.usagetext)
    exit(Int32(error._code))
}

