import simd

public enum KAMeshAnimationChannelType {
    case translation(values: [SIMD3<Float>])
    case rotation(values: [simd_quatf])
    case scale(values: [SIMD3<Float>])
}
