Class {
	#name : #GtLepiterDatabaseShapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'pageSnapshots',
		'databaseUuid',
		'databaseName'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance creation' }
GtLepiterDatabaseShapshot class >> fromDatabase: aDatabase [
	^ self new
		initializeFromDatabase: aDatabase
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> databaseName [

	^ databaseName
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> databaseName: anObject [

	databaseName := anObject
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> databaseUuid [

	^ databaseUuid
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> databaseUuid: anObject [

	databaseUuid := anObject
]

{ #category : #initialization }
GtLepiterDatabaseShapshot >> initializeFromDatabase: aDatabase [ 
	self databaseUuid: aDatabase uuid.
	self databaseName: aDatabase databaseName.
	self pageSnapshots: (aDatabase pages collect: [ :aPage | 
		GtLepiterPageSnapshot fromPage: aPage ])
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> pageSnapshots [
	^ pageSnapshots
]

{ #category : #accessing }
GtLepiterDatabaseShapshot >> pageSnapshots: aCollection [
	pageSnapshots := aCollection
]
