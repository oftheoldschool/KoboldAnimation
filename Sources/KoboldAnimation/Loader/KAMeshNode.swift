import simd

public struct KAMeshNode {
    let name: String
    let id: Int
    let parentId: Int
    let translation: SIMD3<Float>
    let rotation: simd_quatf
    let scale: SIMD3<Float>

    public init(
        name: String,
        id: Int,
        parentId: Int,
        translation: SIMD3<Float>,
        rotation: simd_quatf,
        scale: SIMD3<Float>
    ) {
        self.name = name
        self.id = id
        self.parentId = parentId
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }
}
