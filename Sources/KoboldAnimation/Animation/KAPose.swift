import simd

public class KAPose: Equatable {
    var joints: [Joint]
    var skeletonToNode: [Int:Int]
    
    init(joints: [Joint], skeletonToNode: [Int:Int]) {
        self.joints = joints
        self.skeletonToNode = skeletonToNode
    }
    
    public func getMatrixPalette() -> [float4x4] {
        return self.joints.map { $0.getGlobalTransform(joints: self.joints).toMat4() }
    }
    
    public func clone() -> KAPose {
        return KAPose(
            joints: joints.map { $0.clone() }, 
            skeletonToNode: skeletonToNode)
    }
    
    public static func == (lhs: KAPose, rhs: KAPose) -> Bool {
        return lhs.joints.elementsEqual(rhs.joints)
    }
}
