import CoreGraphics
import Foundation

/// Static stage definitions. The four stages stack vertically: dorm → garage → office →
/// warehouse (design §11). Each reuses the dorm room geometry with a distinct color tint +
/// name banner for now; bespoke per-room art is a later polish pass.
enum Stages {
    /// Shared floor slots (room-local coords) where purchased GPUs appear, in order.
    private static let floorSlots: [CGPoint] = [
        CGPoint(x: 120, y: 180), CGPoint(x: 160, y: 180), CGPoint(x: 200, y: 180), CGPoint(x: 240, y: 180),
        CGPoint(x: 120, y: 140), CGPoint(x: 160, y: 140), CGPoint(x: 200, y: 140), CGPoint(x: 240, y: 140),
        CGPoint(x: 140, y: 108), CGPoint(x: 220, y: 108)
    ]

    static let dorm = StageDefinition(
        id: "dorm",
        displayName: "Dorm Room",
        gearCatalog: [
            // The cheapest item MUST be affordable from the $500 start (design §6b).
            GearDefinition(id: "used_gpu",    displayName: "Used GPU",    cost: 150,    computePerSecond: 4,   spriteName: "gear_used_gpu"),
            GearDefinition(id: "rtx4090",     displayName: "RTX 4090",    cost: 800,    computePerSecond: 12,  spriteName: "gear_rtx4090"),
            GearDefinition(id: "h100",        displayName: "H100",        cost: 5_000,  computePerSecond: 60,  spriteName: "gear_h100"),
            GearDefinition(id: "server_rack", displayName: "Server Rack", cost: 28_000, computePerSecond: 250, spriteName: "gear_server_rack")
        ],
        gearSlots: floorSlots,
        unlockPrice: 0,
        computeToCashRate: 0.5,
        roomTint: .none
    )

    static let garage = StageDefinition(
        id: "garage",
        displayName: "Garage",
        gearCatalog: [
            GearDefinition(id: "a100",        displayName: "A100",         cost: 12_000,  computePerSecond: 400,    spriteName: "gear_a100"),
            GearDefinition(id: "dgx_station", displayName: "DGX Station",  cost: 60_000,  computePerSecond: 1_200,  spriteName: "gear_dgx"),
            GearDefinition(id: "rack_cluster",displayName: "Rack Cluster", cost: 250_000, computePerSecond: 5_000,  spriteName: "gear_cluster"),
            GearDefinition(id: "cooling_pod", displayName: "Cooling Pod",  cost: 900_000, computePerSecond: 18_000, spriteName: "gear_cooling")
        ],
        gearSlots: floorSlots,
        unlockPrice: 5_000,
        computeToCashRate: 0.8,
        roomTint: RGBA(r: 0.20, g: 0.26, b: 0.38, a: 0.22)
    )

    static let office = StageDefinition(
        id: "office",
        displayName: "Office",
        gearCatalog: [
            GearDefinition(id: "tpu_pod",     displayName: "TPU Pod",       cost: 1_500_000,  computePerSecond: 40_000,    spriteName: "gear_tpu"),
            GearDefinition(id: "gpu_pod",     displayName: "GPU SuperPod",  cost: 7_000_000,  computePerSecond: 150_000,   spriteName: "gear_superpod"),
            GearDefinition(id: "datacenter_row", displayName: "DC Row",     cost: 30_000_000, computePerSecond: 600_000,   spriteName: "gear_dcrow"),
            GearDefinition(id: "liquid_loop", displayName: "Liquid Loop",   cost: 120_000_000,computePerSecond: 2_400_000, spriteName: "gear_liquid")
        ],
        gearSlots: floorSlots,
        unlockPrice: 75_000,
        computeToCashRate: 1.2,
        roomTint: RGBA(r: 0.50, g: 0.42, b: 0.20, a: 0.18)
    )

    static let warehouse = StageDefinition(
        id: "warehouse",
        displayName: "Warehouse",
        gearCatalog: [
            GearDefinition(id: "pod_hall",    displayName: "Pod Hall",      cost: 500_000_000,    computePerSecond: 10_000_000,  spriteName: "gear_podhall"),
            GearDefinition(id: "mega_cluster",displayName: "Mega Cluster",  cost: 2_500_000_000,  computePerSecond: 45_000_000,  spriteName: "gear_mega"),
            GearDefinition(id: "fusion_feed", displayName: "Fusion Feed",   cost: 12_000_000_000, computePerSecond: 200_000_000, spriteName: "gear_fusion"),
            GearDefinition(id: "agi_array",   displayName: "AGI Array",     cost: 60_000_000_000, computePerSecond: 900_000_000, spriteName: "gear_agi")
        ],
        gearSlots: floorSlots,
        unlockPrice: 1_000_000,
        computeToCashRate: 2.0,
        roomTint: RGBA(r: 0.15, g: 0.30, b: 0.20, a: 0.25)
    )

    /// All stages in vertical order (top → bottom).
    static let all: [StageDefinition] = [dorm, garage, office, warehouse]

    /// Flat lookup of every gear across all stages, by id. Used so that gear bought in
    /// earlier stages keeps producing compute after the player advances (design §6).
    static let gearByID: [String: GearDefinition] = Dictionary(
        uniqueKeysWithValues: all.flatMap { $0.gearCatalog }.map { ($0.id, $0) }
    )
}
