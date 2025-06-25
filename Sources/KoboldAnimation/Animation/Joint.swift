class Joint: Equatable {
    let name: String
    var parent: Int
    var transform: Transform
    
    init(name: String, parent: Int, transform: Transform) {
        self.name = name
        self.parent = parent
        self.transform = transform
    }
    
    func getGlobalTransform(joints: [Joint]) -> Transform {
        var nextParent = parent
        var result: Transform = self.transform
        while nextParent >= 0 {
            let p = joints[nextParent]
            result = p.transform.combine(result)
            nextParent = p.parent
        }
        return result
    }
    
    static func == (lhs: Joint, rhs: Joint) -> Bool {
        return lhs.parent == rhs.parent && lhs.transform == rhs.transform
    }
    
    func clone() -> Joint {
        return Joint(
            name: name,
            parent: parent,
            transform: transform)
    }
}
