//
//  AristaErrorTests.swift
//  AristaTests
//
//  Created by Jules on 22/05/2024.
//

import XCTest
@testable import Arista

final class AristaErrorTests: XCTestCase {

    func test_AristaError_PersistenceFailureDescription() {
        // Given
        let error = AristaError.persistenceFailure

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "Impossible de charger la base de données. Veuillez redémarrer l'application.")
    }

    func test_AristaError_SaveFailedDescription() {
        // Given
        let error = AristaError.saveFailed

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "L'enregistrement a échoué. Vérifiez vos informations.")
    }

    func test_AristaError_FetchFailedDescription() {
        // Given
        let error = AristaError.fetchFailed

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "Nous n'avons pas pu récupérer vos données.")
    }
}
