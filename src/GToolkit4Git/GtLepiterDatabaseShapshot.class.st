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

{ #category : #'gt-extensions' }
GtLepiterDatabaseShapshot >> gtViewPageSnapshotsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Page Snapshots';
		items: [ self pageSnapshots ];
		column: 'Uuid' text: [ :aPageSnapshot | aPageSnapshot pageUuid asString36 ];
		column: 'Title' text: [ :aPageSnapshot | aPageSnapshot pageTitle ]
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

{ #category : #printing }
GtLepiterDatabaseShapshot >> printOn: aStream [
	super printOn: aStream.
	aStream 
		<< '(';
		<< self databaseName;
		<< ', ';
		<< self databaseUuid asString36;
		<< ')'
]
