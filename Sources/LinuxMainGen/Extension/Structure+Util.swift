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
            .compactMap { Structure(sourceKitResponse: $0) }
            .contains(where: { $0.name == "allTests" })
    }
    
    func `extension`() -> Structure? {
        
        return substructure
            .compactMap { Structure(sourceKitResponse: $0) }
            .first(where: { $0.isExtension })
    }
    
    func `class`(parentClasses: [String]) -> Structure? {
        
        guard let firstClass = Structure.classInStructure(self) else {
            return nil
        }
        
        if firstClass.inheritedTypes.contains(where: { parentClasses.contains($0) }) {
            return firstClass
        } else {
            guard let nestedClass = Structure.classInStructure(firstClass) else {
                return nil
            }
            guard nestedClass.inheritedTypes.contains(where: { parentClasses.contains($0) }) else {
                return nil
            }
            guard let firstClassName = firstClass.name,
                let nestedClassName = nestedClass.name else {
                return nil
            }
            var nestedStructure = nestedClass.dictionary
            nestedStructure["key.name"] = [firstClassName, nestedClassName].joined(separator: ".")
            return Structure(sourceKitResponse: nestedStructure)
        }
    }
    
    func scopes(parentClasses: [String]) -> [Structure] {
        return Structure.scopesInStructure(self)
    }
    
    func testCases() -> [String] {
        
        return substructure
            .compactMap { Structure(sourceKitResponse: $0) }
            .filter { $0.isTestFunction }
            .compactMap { $0.name?.replacingOccurrences(of: "()", with: "") }
    }
    
    static func classInStructure(_ structure: Structure) -> Structure? {
        
        return structure
            .substructure
            .compactMap { Structure(sourceKitResponse: $0) }
            .first(where: { $0.isClass })
    }
    
    static func scopesInStructure(_ structure: Structure) -> [Structure] {
        
        return structure
            .substructure
            .compactMap { Structure(sourceKitResponse: $0) }
            .filter { $0.isClass || $0.isExtension }
    }
}
