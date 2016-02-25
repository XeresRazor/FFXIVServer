import PackageDescription

let package = Package(
    name: "FFXIVServer",
    dependencies: [
        .Package(url: "https://github.com/XeresRazor/SMGOLFramework.git", majorVersion: 0)
//        .Package(url: "file:///Users/dagre/Library/Mobile Documents/com~apple~CloudDocs/Projects/OpenSource/SMGOLFramework", majorVersion: 0)
    ]
)