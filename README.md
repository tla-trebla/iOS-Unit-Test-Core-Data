# iOS-Unit-Test-Core-Data
Learn how to do unit testing for Core Data in Swift based on article "Unit Testing Core Data in iOS" by Ray Wenderlich.
Link: https://www.raywenderlich.com/11349416-unit-testing-core-data-in-ios#toc-anchor-016

# Things I've Learned
* To separate persistence store of Simulator & Unit Testing, use an in-memory store (NSInMemoryStoreType).
* There are also 3 different store type: 
  * NSSQLiteStoreType is by default used by Simulator.
  * NSXMLStoreType is backed by XML file.
  * NSBinaryStoreType is backed by binary data file.
* To check if it saves to the persistent store, we can use an asynchronous test by checking if there's a save signal (NSManagedObjectContextDidSave).
  * Create a background context to perform a background test.
  * Wait the signal at waitForExpectations method.
* Don't forget to apply TDD.
