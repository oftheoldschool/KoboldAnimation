import simd

public class KAAnimationLoader {
    public init() {
    }

    public func loadAnimationData(
        skins: [KAMeshSkin],
        nodes: [KAMeshNode],
        animations: [KAMeshAnimation]
    ) -> KAAnimationData {

        let restPose = loadRestPose(nodes: nodes)
        let bindPose = loadBindPose(skins: skins, restPose: restPose)
        let inverseBindPose = bindPose.joints.map { joint in
            joint.getGlobalTransform(joints: bindPose.joints).toMat4().inverse
        }
        return KAAnimationData(
            skeleton: KASkeleton(
                restPose: restPose,
                bindPose: bindPose,
                inverseBindPose: inverseBindPose),
            animations: loadAnimationClips(animations: animations))
    }

    func loadRestPose(nodes: [KAMeshNode]) -> KAPose {
        return KAPose(
            joints: nodes.map { node in
                Joint(
                    name: node.name,
                    parent: node.parentId,
                    transform: KATransform(
                        position: node.translation,
                        rotation: node.rotation,
                        scale: node.scale))
            },
            skeletonToNode: [:])
    }

    private func loadBindPose(
        skins: [KAMeshSkin],
        restPose: KAPose
    ) -> KAPose {
        var worldBindPose: [KATransform] = restPose.joints.map { joint in
            joint.getGlobalTransform(joints: restPose.joints)
        }

        var skeletonToNode: [Int:Int] = [:]
        skins.forEach { skin in
            (0..<skin.joints.count).forEach { i in
                let inverseBindMatrix = skin.inverseBindMatrices[i]
                let bindMatrix = inverseBindMatrix.inverse
                let bindTransform = KATransform(fromMatrix: bindMatrix)
                worldBindPose[skin.joints[i].id] = bindTransform
                skeletonToNode[i] = skin.joints[i].id
            }
        }
        let bindPose = restPose.clone()

        let updatedJoints = bindPose.joints.enumerated().map { i, joint in
            var currentTransform = worldBindPose[i]
            let parentId = joint.parent
            if parentId >= 0 {
                let parentTransform = worldBindPose[parentId]
                currentTransform = parentTransform.inverse().combine(currentTransform)
            }
            return Joint(name: joint.name, parent: joint.parent, transform: currentTransform)
        }
        return KAPose(joints: updatedJoints, skeletonToNode: skeletonToNode)
    }

    private func loadAnimationClips(animations: [KAMeshAnimation]) -> [String: KAClip] {
        return animations.reduce(into: [:]) { acc, next in
            acc[next.name] = animationToClip(animation: next)
        }
    }

    private func animationToClip(animation: KAMeshAnimation) -> KAClip {
        let tracks = animation.channels.map { channel in
            var positionTrack: KATrackFVec3? = nil
            var rotationTrack: KATrackFQuat? = nil
            var scaleTrack: KATrackFVec3? = nil

            let interpolation: KAInterpolation = switch channel.interpolation {
            case .constant: .constant
            case .linear: .linear
            case .cubic: .cubic
            }

            switch channel.type {
            case .translation(let values): positionTrack =
                KATrackFVec3(
                    interpolation: interpolation,
                    time: channel.time,
                    values: values)
            case .scale(let values): scaleTrack =
                KATrackFVec3(
                    interpolation: interpolation,
                    time: channel.time,
                    values: values)
            case .rotation(let values): rotationTrack =
                KATrackFQuat(
                    interpolation: interpolation,
                    time: channel.time,
                    values: values)
            }

            return KATransformTrack(
                joint: channel.id,
                position: positionTrack,
                rotation: rotationTrack,
                scale: scaleTrack)
        }

        return KAClip(
            name: animation.name,
            looping: true,
            tracks: tracks)
    }
}
