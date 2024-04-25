//
//  PatchFormat.swift
//
//
//  Created by Mark Feaver on 25/4/2024.
//

public enum PatchFormat: String {
    case ips = "IPS"
    case ups = "UPS"
    case aps = "APS"  // Typically for N64/GBA
    case bps = "BPS"
    case rup = "RUP"
    case ppf = "PPF"
    case mod = "MOD"  // For Paper Mario Star Rod
    case vcdiff = "VCDiff"  // Also includes .xdelta files

    static func from(fileExtension: String) -> PatchFormat? {
        switch fileExtension.lowercased() {
        case "ips": return .ips
        case "ups": return .ups
        case "aps": return .aps
        case "bps": return .bps
        case "rup": return .rup
        case "ppf": return .ppf
        case "mod": return .mod
        case "xdelta", "vcdiff": return .vcdiff
        default: return nil
        }
    }
}
