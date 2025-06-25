import simd

public class KASkeleton {
    let restPose: KAPose
    public let bindPose: KAPose
    public let inverseBindPose: [float4x4]

    init(
        restPose: KAPose,
        bindPose: KAPose,
        inverseBindPose: [float4x4]
    ) {
        self.restPose = restPose
        self.bindPose = bindPose
        self.inverseBindPose = inverseBindPose
    }
}
