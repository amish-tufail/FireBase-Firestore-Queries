//
//  FB_QueriesApp.swift
//  FB Queries
//
//  Created by Amish Tufail on 02/02/2023.
//

import SwiftUI
import Firebase
@main
struct FB_QueriesApp: App {
    init() {
        // Initializes the Firebase
        FirebaseApp.configure()
//        makeReservations()
//        updateReservations()
//        deleteReservations()
//        handleErrors()
//        readData()
//        queryData()
        compoundQuery()
    }
    // MARK: CREATE DOCUMENT
    func makeReservations() {
        let db = Firestore.firestore() // This refers to Google.info.plist ot get our required DB.
        let reservations = db.collection("reservations") // This allows us to access our reservations collection but if it was not their then it would create it.
        // Create a document with a given indentifier
        reservations.document("test123") // Creates a new document with a given identifer, but if it already exist then it will refer to it
            .setData(
                [
                    "name" : "Amish",
                    "age" : 21
                ]
            ) // To add data
        
        // Create a document with a unique indentifier
        reservations.document() // This creates a document with an auto generated unique identifier
            .setData(
                [
                    "name" : "Anis"
                ]
            )

        // Create a document with given data
        let document = reservations.addDocument(data: // This creates a document with an auto generated unique identifier and adds the data
                [
                    "name" : "Tufail"
                ]
        )
    }
    
    // MARK: UPDATE DATA
    func updateReservations() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        let document = reservations.document("test123")
        
        document.setData(["name" : "XYZ", "age" : 40]) // This overwrites the data.
        document.setData(["age" : 20]) // This overwrites the data, but has a problem that all the previous and next field are deleted and only this one remains. So, to solve this...
        document.setData(["age" : 20], merge: true) // This solves the problem, it merges this change into the document
        
        document.updateData(["name" : "Amish"]) // This method updates the data and auto merges it
        document.updateData(["age" : 21])
    }
    
    // MARK: DELETE DATA
    func deleteReservations() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        let document = reservations.document("reservations")
        
        document.updateData(["name" : FieldValue.delete()]) // This will delete the following field from the document
        document.delete() // This will delete the entire document.
    }
    
    // MARK: HANDLE ERRORS
    func handleErrors() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        let document = reservations.document("reservations")
        
        // In order to handle errors we use completion handlers
        
        document.updateData(["age" : 21]) { error in
            // If there is an error we deal with it in if
            if let error = error {
                print(error.localizedDescription)
            // else we return nothing
            } else {
                return
            }
        }
        document.delete()
        
        document.updateData(["name" : "Anis", "age" : 16]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                 return
            }
        }
         // So we deleted documented before and then are updating data to a document which does not exist anymore so, an error will be thrown
    }
    
    // MARK: READ DATA
    func readData() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        let document = reservations.document("test123")
        
        // METHODS:
        //          1. Read doc once and get the info at once/single call
        //          2. Listen to changes to doc, and then get doc when a change is made to a doc
        
        // METHOD: 1
        
        // For Single Document in a collection
       
        document.getDocument { docSnapshot, error in // docSnapshot has all the details/info of the given document and all of its changes and data
            if let error = error {
                // We handle the error in here
                print(error.localizedDescription)
            } else if let docSnapshot = docSnapshot {
                // We handle the data in here
                print(docSnapshot.data()!) // It prints all the data in the document in the form of a dict
                print(docSnapshot.documentID) // This prints its id
            } else {
                // No data was retrieved and handle this case approp
            }
        }
        
        // For all the documents in the collection
        reservations.getDocuments { querySnapshot, error in
            if let error = error {
                // We handle the error in here
                print(error.localizedDescription)
            } else if let querySnapshot = querySnapshot {
                // We handle the data in here
                for doc in querySnapshot.documents {
                    print(doc.data())
                    print(doc.documentID)
                }
            } else {
                // No data was retrieved and handle this case approp
            }
        }
        
        // METHOD: 2
        
        // For one document
        document.addSnapshotListener { docSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let docSnapshot = docSnapshot {
                print(docSnapshot.data()!) // Prints the data whenever any data changes in this document
            } else {
                return
            }
        }
        
        // For all the documents in a collection
        reservations.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let querySnapshot = querySnapshot {
                for doc in querySnapshot.documents {
                    print(doc.data()) // This prints the data of all documents in a collection at once, and it we change any one document then again all the documents in the collection with their data get printed. So, what if we want to only print the document change one only. Solution...
                }
                for doc in querySnapshot.documentChanges {
                    print(doc.document.data()) // This is the solution. At first time it prints the data of the documents, after thatv only prints the data of the document that is changes only.
                }
                
            } else {
                return
            }
        }
        
        // Difference between Method 1 and Method 2
        // Method 1 calls the data once, while method 2 calls the data whenever it get changes
    }
    
    // MARK: QUERY DATA
    func queryData() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        
        let query = reservations.whereField("name", in: ["Amish", "Anis"]) // This will return documents that have name field is Amish or Anis
        query.getDocuments { querySnapshot, error in // Now we get the document
            for doc in querySnapshot!.documents {
                print(doc.data())
            }
        }
        
        // Different Types of queries
        reservations.whereField("name", notIn: ["Amish", "Anis"]) // This will return documents that have name field not Amish or Anis
        reservations.whereField("array", arrayContains: 1) // This return the doc which array has 1
        reservations.whereField("array", arrayContainsAny: [1, 2, 3]) // This return the doc which array has 1, 2, 3
        // ... And many more
    }
    
    func compoundQuery() {
        let db = Firestore.firestore()
        let reservations = db.collection("reservations")
        
        let query = reservations
            .whereField("name", in: ["Amish", "Anis"])
            .whereField("people", isLessThan: 60)
        query.getDocuments { querySnapShot, error in
            if let querySnapShot = querySnapShot {
                for doc in querySnapShot.documents {
                    print(doc.data())
                }
            }
        }
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
