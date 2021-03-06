//
//  VisitorProfileTests.swift
//  TealiumSwiftTests
//
//  Created by Christina Sund on 5/16/19.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
@testable import TealiumVisitorService
import XCTest

class VisitorProfileTests: XCTestCase {

    var visitorJSON: Data!
    var visitorEmpties: Data!
    var visitorNils: Data!
    var visitorAllNil: Data!
    var visitor: TealiumVisitorProfile!
    let decoder = JSONDecoder()

    override func setUp() {
        visitorJSON = loadStub(from: "visitor", with: "json")
        visitorNils = loadStub(from: "visitor-nils", with: "json")
        visitorEmpties = loadStub(from: "visitor-empties", with: "json")
        visitorAllNil = loadStub(from: "visitor-all-nil", with: "json")
    }

    func testCodableObjectReturnsExpectedData() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        guard let currentVisit = visitor.currentVisit else {
            XCTFail("CurrentVisit does not conform to protocol")
            return
        }

        XCTAssertEqual(visitor.audiences?[id: "110"], true)
        XCTAssertEqual(visitor.audiences?[name: "ios users"], true)
        XCTAssertEqual(visitor.audiences?[name: "nope"], false)
        XCTAssertEqual(visitor.badges?["8535"], true)
        XCTAssertEqual(visitor.badges?["6301"], true)
        XCTAssertEqual(visitor.badges?["9999"], false)
        XCTAssertNotNil(visitor.tallies?[tally: "8481"])
        XCTAssertNil(visitor.tallies?[tally: "9999"])
        XCTAssertEqual(visitor.tallies?[tally: "8481", key: "category 5"], 12.0)
        XCTAssertEqual(visitor.tallies?[tally: "8481", key: "category 99"], nil)
        XCTAssertNotNil(currentVisit.strings?["44"])
        XCTAssertNotNil(currentVisit.strings?["44"])
        XCTAssertNotNil(currentVisit.strings?["44"])
        XCTAssertNil(currentVisit.strings?["999"])
        XCTAssertNotNil(currentVisit.dates?["11"])
    }

    func testCodableWithNils() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorNils)
        XCTAssertNil(visitor.tallies)
        XCTAssertNil(visitor.strings)
        XCTAssertNotNil(visitor.dates)
        XCTAssertNotNil(visitor.arraysOfStrings)
        XCTAssertNil(visitor.currentVisit)
    }

    func testCodableWithoutCertainKeys() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorEmpties)
        guard let currentVisit = visitor.currentVisit else {
            XCTFail("CurrentVisit does not conform to protocol")
            return
        }
        XCTAssertNil(visitor.audiences)
        XCTAssertNil(visitor.strings)
        XCTAssertNotNil(visitor.dates)
        XCTAssertNotNil(visitor.tallies)
        XCTAssertNil(currentVisit.setsOfStrings)
        XCTAssertNotNil(currentVisit.arraysOfBooleans)
    }

    func testAudienceSubscriptByName() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let correctCasing = visitor.audiences?[name: "iOS Users"] {
            XCTAssertTrue(correctCasing)
        }
        if let lowercased = visitor.audiences?[name: "ios users"] {
            XCTAssertTrue(lowercased)
        }
        if let uppercased = visitor.audiences?[name: "IOS USERS"] {
            XCTAssertTrue(uppercased)
        }
    }

    func testAudienceSubscriptById() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let audienceAExists = visitor.audiences?[id: "110"] {
            XCTAssertEqual(true, audienceAExists)
        }
        if let audienceBExists = visitor.audiences?[id: "103"] {
            XCTAssertEqual(true, audienceBExists)
        }
    }

    func testOtherAttributesById() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        guard let currentVisit = visitor.currentVisit else {
            XCTFail("CurrentVisit does not conform to protocol")
            return
        }
        if let badge = visitor.badges?["8535"] {
            XCTAssertTrue(badge)
        }
        if let date = visitor.dates?["23"] {
            XCTAssertEqual(1_557_421_336_000, date)
        }
        if let boolean = visitor.booleans?["27"] {
            XCTAssertTrue(boolean)
        }
        if let arrayOfBools = currentVisit.arraysOfBooleans?["8479"] {
            XCTAssertEqual([true, false, true, false, true, false, true, false], arrayOfBools)
        }
        if let number = visitor.numbers?["25"] {
            XCTAssertEqual(27.983_333_333_333_334, number)
        }
        if let arrayOfNumbers = visitor.arraysOfNumbers?["8487"] {
            XCTAssertEqual([3.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], arrayOfNumbers)
        }
        if let tally = visitor.tallies?[tally: "8481"] {
            XCTAssertNotNil(tally)
        }

        if let tallyValue = visitor.tallies?[tally: "8481", key: "category 3"] {
            XCTAssertEqual(1.0, tallyValue)
        }

        if let string = visitor.strings?["8480"] {
            XCTAssertEqual("category 5", string)
        }
        if let stringArray = visitor.arraysOfStrings?["8483"] {
            XCTAssertEqual(["category 4", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5"], stringArray)
        }
        if let stringSet = currentVisit.setsOfStrings?["50"] {
            XCTAssertEqual(["Mac OS X"], stringSet)
        }
    }

    func testAudienceSubscriptByNameNil() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorNils)
        if let shouldNotExistInProfile = visitor.audiences?[name: "iOS User"] {
            XCTAssertEqual(false, shouldNotExistInProfile)
        }
        XCTAssertTrue(true)
    }

    func testAudienceSubscriptByIdNil() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorNils)
        if let shouldNotExistInProfile = visitor.audiences?[id: "112"] {
            XCTAssertEqual(false, shouldNotExistInProfile)
        }
        XCTAssertTrue(true)
    }

    func testOtherAttributesByIdNil() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorNils)
        guard let _ = visitor.currentVisit else {
            XCTAssertTrue(true, "CurrentVisit is nil so this block should be hit")
            return
        }
        if let _ = visitor.tallies?[tally: "8481"] {
            XCTFail("Should not return any tallies")
        }

        if let _ = visitor.strings?["8480"] {
            XCTFail("Should not return any strings")
        }

        XCTAssertTrue(true)
    }

    func testBadgesSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.badges?["9999"] {
            XCTAssertEqual(false, shouldNotExistInProfile)
        }
        XCTAssertTrue(true)
    }

    func testBadgesSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.badges?["8535"] {
            XCTAssertEqual(true, shouldExistInProfile)
        }
    }

    func testBadgesSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.badges?["9999"] {
               XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testBooleansSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.booleans?["9999"] {
            XCTAssertEqual(true, shouldNotExistInProfile)
        }
    }

    func testBooleansSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.booleans?["27"] {
            XCTAssertEqual(true, shouldExistInProfile)
        }
    }

    func testBooleansSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.booleans?["9999"] {
            XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testArrayOfBooleansSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let currentVisit = visitor.currentVisit, let shouldNotExistInProfile = currentVisit.arraysOfBooleans?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testArrayOfBooleansSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let currentVisit = visitor.currentVisit, let shouldExistInProfile = currentVisit.arraysOfBooleans?["27"] {
            XCTAssertEqual([true, false, true, false, true, false, true, false], shouldExistInProfile)
        }
    }

    func testArrayOfBooleansSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
        if let currentVisit = visitor.currentVisit, let _ = currentVisit.arraysOfBooleans?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testDatesSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.dates?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testDatesSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.dates?["5089"] {
            XCTAssertEqual(1_557_777_940_471, shouldExistInProfile)
        }
    }

    func testDatesSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.dates?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testNumbersSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.numbers?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testNumbersSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.numbers?["22"] {
            XCTAssertEqual(25.0, shouldExistInProfile)
        }
    }

    func testNumbersSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.numbers?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testArrayOfNumbersSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.arraysOfNumbers?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testArrayOfNumbersSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.arraysOfNumbers?["8487"] {
            XCTAssertEqual([3.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], shouldExistInProfile)
        }
    }

    func testArrayOfNumbersSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.arraysOfNumbers?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testTallySubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.tallies?[tally: "9999"] {
            XCTAssertNil(shouldNotExistInProfile.tallyValue)
        }
    }

    func testTallySubscriptSuccess() {
        let expected: [String: Float] = ["category 1": 2.0,
                          "category 2": 1.0,
                          "category 3": 1.0,
                          "category 4": 1.0,
                          "category 5": 12.0]
        var results = [Bool]()
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.tallies?[tally: "8481"] {
            for tallyValue in shouldExistInProfile.tallyValue where expected[tallyValue.key] == tallyValue.count {
                results.append(true)
            }
        }
        XCTAssertEqual([true, true, true, true, true], results)
    }

    func testTallySubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.tallies?[tally: "9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testTallyValueSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.tallies?[tally: "9999", key: "category 4"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testTallyValueSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.tallies?[tally: "8481", key: "category 4"] {
            XCTAssertEqual(1.0, shouldExistInProfile)
        }
    }

    func testTallyValueSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.tallies?[tally: "9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testVisitorStringSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.strings?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testVisitorStringSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.strings?["8480"] {
            XCTAssertEqual("category 5", shouldExistInProfile)
        }
    }

    func testVisitorStringSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.strings?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testArrayOfStringsSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldNotExistInProfile = visitor.arraysOfStrings?["9999"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testArrayOfStringsSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let shouldExistInProfile = visitor.arraysOfStrings?["8483"] {
            XCTAssertEqual(["category 4", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5", "category 5"], shouldExistInProfile)
        }
    }

    func testArrayOfStringsSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let _ = visitor.arraysOfStrings?["9999"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

    func testSetOfStringsSubscriptNoResult() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let currentVisit = visitor.currentVisit, let shouldNotExistInProfile = currentVisit.setsOfStrings?["27"] {
            XCTAssertNil(shouldNotExistInProfile)
        }
    }

    func testSetOfStringsSubscriptSuccess() {
        visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorJSON)
        if let currentVisit = visitor.currentVisit, let shouldExistInProfile = currentVisit.setsOfStrings?["50"] {
            XCTAssertEqual(["Mac OS X"], shouldExistInProfile)
        }
    }

    func testSetOfStringsSubscriptNil() {
           visitor = try! decoder.decode(TealiumVisitorProfile.self, from: visitorAllNil)
           if let currentVisit = visitor.currentVisit, let _ = currentVisit.setsOfStrings?["27"] {
                XCTFail("Should not get here - nil")
           }
           XCTAssertTrue(true)
       }

}
