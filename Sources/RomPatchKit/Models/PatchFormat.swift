//
//  PatchFormat.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

public enum PatchFormat: String {
    case ips = "ips"
    case ups = "ups"
    case aps = "aps"  // Typically for N64/GBA
    case bps = "bps"
    case rup = "rup"
    case ppf = "ppf"
    case mod = "mod"  // For Paper Mario Star Rod
    case xdelta = "xdelta"
    case vcdiff = "vcdiff"

    static func from(fileExtension: String) -> PatchFormat? {
        switch fileExtension.lowercased() {
        case "ips": return .ips
        case "ups": return .ups
        case "aps": return .aps
        case "bps": return .bps
        case "rup": return .rup
        case "ppf": return .ppf
        case "mod": return .mod
        case "xdelta": return .xdelta
        case "vcdiff": return .vcdiff
        default: return nil
        }
    }
}
