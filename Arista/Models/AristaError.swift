//
//  AristaError.swift
//  Arista
//
//  Created by Mathieu ARRIO on 10/03/2026.
//

import Foundation

enum AristaError: LocalizedError {
    case persistenceFailure
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .persistenceFailure:
            return "Impossible de charger la base de données. Veuillez redémarrer l'application."
        case .saveFailed:
            return "L'enregistrement a échoué. Vérifiez vos informations."
        case .fetchFailed:
            return "Nous n'avons pas pu récupérer vos données."
        }
    }
}
