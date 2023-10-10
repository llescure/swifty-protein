//
//  Utils.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import Foundation
import UIKit

func color(for atomName: String) -> UIColor? {
    switch atomName {
    case "H": return .white
    case "C": return .black
    case "N": return .blue
    case "O": return .red
    case "F", "Cl": return .green
    case "Br": return .brown
    case "I": return .purple
    case "He", "Ne", "Ar", "Xe", "Kr": return .cyan
    case "P": return .orange
    case "S": return .yellow
    case "B": return .magenta
    case "Li", "Na", "K", "Rb", "Cs", "Fr": return .systemTeal
    case "Be", "Mg", "Ca", "Sr", "Ba", "Ra": return .systemIndigo
    case "Ti", "Zr", "Hf", "Rf": return .systemPink
    case "V", "Nb", "Ta", "Db": return .systemPurple
    case "Cr", "Mo", "W", "Sg": return .systemOrange
    case "Mn", "Tc", "Re", "Bh": return .systemYellow
    case "Fe", "Ru", "Os", "Hs": return .systemGreen
    case "Co", "Rh", "Ir", "Mt": return .systemBlue
    case "Ni", "Pd", "Pt", "Ds": return .systemRed
    case "Cu", "Ag", "Au", "Rg": return .systemGray
    case "Zn", "Cd", "Hg", "Cn": return .systemBrown
    case "Al", "Ga", "In", "Tl", "Nh": return .systemTeal
    case "Si", "Ge", "Sn", "Pb", "Fl": return .systemIndigo
    case "As", "Sb", "Bi", "Mc": return .systemPink
    case "Se", "Te", "Po", "Lv": return .systemPurple
    case "At", "Ts", "Og": return .systemOrange
    default: return .yellow
    }
}
