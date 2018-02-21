import SourceKittenFramework

extension Structure {
    
    var isClass: Bool {
        return declarationKind == .class
    }
    
    var isExtension: Bool {
        return declarationKind == .extension
    }
    
    var isFinalClass: Bool {
        return isClass && attributes.contains("source.decl.attribute.final")
    }
    
    var isTestFunction: Bool {
        return declarationKind == .functionMethodInstance && name?.hasPrefix("test") == true
    }
    
    var isAllTestsExtension: Bool {
        
        return substructure
            .flatMap { Structure(sourceKitResponse: $0) }
            .contains(where: { $0.name == "allTests" })
    }
    
    func `extension`() -> Structure? {
        
        return substructure
            .flatMap { Structure(sourceKitResponse: $0) }
            .first(where: { $0.isExtension })
    }
    
    func `class`(parentClasses: [String]) -> Structure? {
        
        return substructure
            .flatMap { Structure(sourceKitResponse: $0) }
            .first(where: { $0.isClass && $0.inheritedTypes.contains(where: { parentClasses.contains($0) }) })
    }
    
    func testCases() -> [String] {
        
        return substructure
            .flatMap { Structure(sourceKitResponse: $0) }
            .filter { $0.isTestFunction }
            .flatMap { $0.name?.replacingOccurrences(of: "()", with: "") }
    }
}
