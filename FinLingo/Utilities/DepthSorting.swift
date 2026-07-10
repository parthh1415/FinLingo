//
//  DepthSorting.swift
//  FinLingo
//
//  Y-sorted depth ("painter's order") for top-down pixel-art objects.
//
//  In a top-down scene, an object lower on screen (smaller scene Y) should draw
//  IN FRONT of an object higher up. SpriteKit draws higher `zPosition` last
//  (i.e. on top), so we map a lower base Y to a higher z.
//
//  This replaces fixed z-layering for "sortable" nodes (design §9, decision D6).
//  Sortable nodes (furniture instances, gear, the player) receive a z inside a
//  reserved band that sits between the static furniture base layer and the
//  foreground/HUD layers defined in `PixelArtStyle.Layer` (furniture ~10,
//  player ~20, foreground ~30 — defined elsewhere, not redefined here).
//

import SpriteKit

/// Namespace for y-sorted depth helpers. All members are pure except `apply`,
/// which writes `node.zPosition`.
enum DepthSorting {

    /// The bottom of the z band reserved for y-sorted objects. Sits just above
    /// the static furniture base layer (`PixelArtStyle.Layer.furniture` ~ 10).
    static let bandBase: CGFloat = 10

    /// The height of the z band. The band spans roughly
    /// `[bandBase, bandBase + bandHeight]` (~[10, 28]), staying below the
    /// foreground/HUD layers (`PixelArtStyle.Layer.foreground` ~ 30).
    static let bandHeight: CGFloat = 18

    // MARK: - Core mapping

    /// Maps an object's base/contact Y (in scene coordinates) to a `zPosition`
    /// within the reserved band.
    ///
    /// Lower `baseY` (further down the screen) produces a higher z, so it draws
    /// in front. `sceneHeight` normalizes `baseY` into the band.
    ///
    /// Formula:
    ///   n = clamp(baseY / max(sceneHeight, 1), 0, 1)
    ///   z = clamp(bandBase + (1 - n) * bandHeight, bandBase, bandBase + bandHeight)
    ///
    /// Endpoints:
    ///   - `baseY == 0`           → `bandBase + bandHeight` (front-most)
    ///   - `baseY == sceneHeight` → `bandBase`             (back-most)
    ///
    /// - Parameters:
    ///   - baseY: The contact/feet Y of the object in scene coordinates.
    ///   - sceneHeight: The scene height used to normalize `baseY`.
    /// - Returns: A `zPosition` clamped to `[bandBase, bandBase + bandHeight]`.
    static func zPosition(forBaseY baseY: CGFloat, sceneHeight: CGFloat) -> CGFloat {
        let n = clamp(baseY / max(sceneHeight, 1), lower: 0, upper: 1)
        let z = bandBase + (1 - n) * bandHeight
        return clamp(z, lower: bandBase, upper: bandBase + bandHeight)
    }

    // MARK: - Node convenience

    /// Computes the contact/base Y for a sprite node (its bottom/feet edge),
    /// accounting for the node's anchor point and size, then returns the
    /// `zPosition` for that base Y.
    ///
    /// - Parameters:
    ///   - node: The sprite to sort.
    ///   - sceneHeight: The scene height used to normalize the base Y.
    /// - Returns: A `zPosition` clamped to `[bandBase, bandBase + bandHeight]`.
    static func zPosition(for node: SKSpriteNode, sceneHeight: CGFloat) -> CGFloat {
        zPosition(forBaseY: baseY(of: node), sceneHeight: sceneHeight)
    }

    /// Applies the y-sorted `zPosition` to `node` in place. This is the only
    /// member with a side effect.
    ///
    /// - Parameters:
    ///   - node: The sprite whose `zPosition` is set.
    ///   - sceneHeight: The scene height used to normalize the base Y.
    static func apply(to node: SKSpriteNode, sceneHeight: CGFloat) {
        node.zPosition = zPosition(for: node, sceneHeight: sceneHeight)
    }

    // MARK: - Helpers

    /// The base (bottom/contact) Y of a sprite, accounting for its anchor and
    /// size: `position.y - anchorPoint.y * size.height`.
    ///
    /// For the common anchor `(0.5, 0.5)` this is the vertical center minus half
    /// the height (the bottom edge). For an anchor of `(0.5, 0)` it equals
    /// `position.y` (the node is already anchored at its feet).
    static func baseY(of node: SKSpriteNode) -> CGFloat {
        node.position.y - (node.anchorPoint.y * node.size.height)
    }

    /// Clamps `value` to the inclusive range `[lower, upper]`.
    private static func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }
}
