/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
@testable import PandemicReport
import CoreData

class ReportServiceTests: XCTestCase {
  
  var reportService: ReportService!
  var coreDataStack: CoreDataStack!
  
  override func setUp() {
    super.setUp()
    coreDataStack = TestCoreDataStack()
    reportService = ReportService(managedObjectContext: coreDataStack.mainContext,
                                  coreDataStack: coreDataStack)
  }
  
  override func tearDown() {
    super.tearDown()
    reportService = nil
    coreDataStack = nil
  }
  
  func testAddReport() {
    // 1
    let report = reportService.add("Death Star",
                                   numberTested: 1000,
                                   numberPositive: 999,
                                   numberNegative: 1)
    
    // 2
    XCTAssertNotNil(report, "Report should not be nil")
    XCTAssertTrue(report.location == "Death Star")
    XCTAssertTrue(report.numberTested == 1000)
    XCTAssertTrue(report.numberPositive == 999)
    XCTAssertTrue(report.numberNegative == 1)
    XCTAssertNotNil(report.id, "id should not be nil")
    XCTAssertNotNil(report.dateReported, "dateReported should not be nil")
  }
  
  func testRootContextIsSavedAfterAddingReport() {
    // 1
    let derivedContext = coreDataStack.newDerivedContext()
    reportService = ReportService(managedObjectContext: derivedContext,
                                  coreDataStack: coreDataStack)
    
    // 2
    expectation(forNotification: .NSManagedObjectContextDidSave,
                object: coreDataStack.mainContext) { _ in
      return true
    }
    
    // 3
    derivedContext.perform {
      let report = self.reportService.add("Death Star 2",
                                          numberTested: 600,
                                          numberPositive: 599,
                                          numberNegative: 1)
      
      XCTAssertNotNil(report)
    }
    
    // 4
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save did not occur")
    }
  }
  
  func testGetReports() {
    // 1
    let newReport = reportService.add("Endor",
                                      numberTested: 30,
                                      numberPositive: 20,
                                      numberNegative: 10)
    
    // 2
    let getReports = reportService.getReports()
    
    // 3
    XCTAssertNotNil(getReports)
    
    // 4
    XCTAssertTrue(getReports?.count == 1)
    
    // 5
    XCTAssertTrue(newReport.id == getReports?.first?.id)
  }
  
  func testUpdateReport() {
    // 1
    let newReport = reportService.add("Snow Planet",
                                      numberTested: 0,
                                      numberPositive: 0,
                                      numberNegative: 0)
    
    // 2
    newReport.numberTested = 30
    newReport.numberPositive = 10
    newReport.numberNegative = 20
    newReport.location = "Hoth"
    
    // 3
    let updateReport = reportService.update(newReport)
    
    // 4
    XCTAssertTrue(newReport.id == updateReport.id)
    
    // 5
    XCTAssertTrue(updateReport.numberTested == 30)
    XCTAssertTrue(updateReport.numberPositive == 10)
    XCTAssertTrue(updateReport.numberNegative == 20)
    XCTAssertTrue(updateReport.location == "Hoth")
  }

  func testDeleteReport() {
    // 1
    let newReport = reportService.add("Starkiller base",
                                      numberTested: 100,
                                      numberPositive: 80,
                                      numberNegative: 20)
    
    // 2
    var fetchReports = reportService.getReports()
    XCTAssertTrue(fetchReports?.count == 1)
    XCTAssertTrue(newReport.id == fetchReports?.first?.id)
    
    // 3
    reportService.delete(newReport)
    
    // 4
    fetchReports = reportService.getReports()
    
    // 5
    XCTAssertTrue(fetchReports?.isEmpty ?? false)
  }
}
