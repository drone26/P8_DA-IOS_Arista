//
//  AristaErrorTests.swift
//  AristaTests
//
//  Created by Jules on 10/03/2026.
//

import XCTest
@testable import Arista

final class AristaErrorTests: XCTestCase {

    func test_persistenceFailure_description() {
        // Given
        let error = AristaError.persistenceFailure

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "Impossible de charger la base de données. Veuillez redémarrer l'application.")
    }

    func test_saveFailed_description() {
        // Given
        let error = AristaError.saveFailed

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "L'enregistrement a échoué. Vérifiez vos informations.")
    }

    func test_fetchFailed_description() {
        // Given
        let error = AristaError.fetchFailed

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "Nous n'avons pas pu récupérer vos données.")
    }
}
