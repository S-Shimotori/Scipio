import Foundation
import Testing
@testable @_spi(Internals) import ScipioKit

struct ManifestLoaderTests {
    // A minimal dump-package payload whose top-level `traits` is the SwiftPM 6.1
    // object form, decoded via PackageManifestKit's TraitDescription model.
    private static let manifestWithObjectFormTraits = """
    {
      "name": "MyFramework",
      "toolsVersion": { "_version": "6.1.0" },
      "dependencies": [],
      "products": [],
      "targets": [],
      "packageKind": { "root": ["/tmp/MyFramework"] },
      "traits": [
        { "name": "default", "enabledTraits": ["Foo"] },
        { "name": "Foo", "description": "bar", "enabledTraits": [] }
      ]
    }
    """

    // Same manifest without a `traits` key.
    private static let manifestWithoutTraits = """
    {
      "name": "MyFramework",
      "toolsVersion": { "_version": "6.1.0" },
      "dependencies": [],
      "products": [],
      "targets": [],
      "packageKind": { "root": ["/tmp/MyFramework"] }
    }
    """

    @Test
    func decodesManifestDeclaringObjectFormTraits() async throws {
        let executor = StubbableExecutor { arguments in
            StubbableExecutorResult(arguments: arguments, success: Self.manifestWithObjectFormTraits)
        }
        let loader = ManifestLoader(executor: executor)

        let manifest = try await loader.loadManifest(for: URL(filePath: "/tmp/MyFramework"))

        #expect(manifest.name == "MyFramework")
        let traits = try #require(manifest.traits)
        #expect(traits.map(\.name) == ["default", "Foo"])
        #expect(traits[0].enabledTraits == ["Foo"])
        #expect(traits[1].description == "bar")
    }

    @Test
    func decodesManifestWithoutTraits() async throws {
        let executor = StubbableExecutor { arguments in
            StubbableExecutorResult(arguments: arguments, success: Self.manifestWithoutTraits)
        }
        let loader = ManifestLoader(executor: executor)

        let manifest = try await loader.loadManifest(for: URL(filePath: "/tmp/MyFramework"))

        #expect(manifest.name == "MyFramework")
    }
}
