import SourceKittenFramework

extension Structure {
    
    var substructure: [[String: SourceKitRepresentable]] {
        let substructure = dictionary["key.substructure"] as? [SourceKitRepresentable] ?? []
        return substructure.flatMap { $0 as? [String: SourceKitRepresentable] }
    }
    
    var name: String? {
        return dictionary["key.name"] as? String
    }
    
    var kind: String? {
        return dictionary["key.kind"] as? String
    }
    
    var offset: Int? {
        return (dictionary["key.offset"] as? Int64).flatMap { Int($0) }
    }
    
    var length: Int? {
        return (dictionary["key.length"] as? Int64).flatMap { Int($0) }
    }
    
    var bodyOffset: Int? {
        return (dictionary["key.bodyoffset"] as? Int64).flatMap { Int($0) }
    }
    
    var bodyLength: Int? {
        return (dictionary["key.bodylength"] as? Int64).flatMap { Int($0) }
    }
    
    var attribute: String? {
        return dictionary["key.attribute"] as? String
    }
    
    var declarationKind: SwiftDeclarationKind? {
        guard let kind = kind else {
            return nil
        }
        
        return SwiftDeclarationKind(rawValue: kind)
    }
    
    var inheritedTypes: [String] {
        let types = dictionary["key.inheritedtypes"] as? [[String: SourceKitRepresentable]] ?? []
        return types.flatMap { Structure(sourceKitResponse: $0).name }
    }
    
    var attributes: [String] {
        let attributes = dictionary["key.attributes"] as? [[String: SourceKitRepresentable]] ?? []
        return attributes.flatMap { Structure(sourceKitResponse: $0).attribute }
    }
}
