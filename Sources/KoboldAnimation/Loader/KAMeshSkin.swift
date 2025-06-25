import simd

public struct KAMeshSkin {
    let inverseBindMatrices: [float4x4]
    let joints: [KAMeshNode]

    public init(
        inverseBindMatrices: [float4x4],
        joints: [KAMeshNode]
    ) {
        self.inverseBindMatrices = inverseBindMatrices
        self.joints = joints
    }
}
