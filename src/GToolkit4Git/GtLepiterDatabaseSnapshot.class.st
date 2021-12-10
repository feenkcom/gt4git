Class {
	#name : #GtLepiterDatabaseSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'databaseUuid',
		'databaseName',
		'localRootRelativePath',
		'propertiesContents',
		'pageSnapshots',
		'attachmentSnapshots',
		'linksSnapshot'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance creation' }
GtLepiterDatabaseSnapshot class >> fromDatabase: aDatabase [
	^ self new
		initializeFromDatabase: aDatabase
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> attachmentSnapshots [

	^ attachmentSnapshots
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> attachmentSnapshots: anObject [

	attachmentSnapshots := anObject
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> databaseName [

	^ databaseName
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> databaseName: anObject [

	databaseName := anObject
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> databaseUuid [

	^ databaseUuid
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> databaseUuid: anObject [

	databaseUuid := anObject
]

{ #category : #'gt-extensions' }
GtLepiterDatabaseSnapshot >> gtViewPageSnapshotsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Page Snapshots';
		items: [ self pageSnapshots ];
		column: 'Uuid' text: [ :aPageSnapshot | aPageSnapshot pageUuid asString36 ];
		column: 'Title' text: [ :aPageSnapshot | aPageSnapshot pageTitle ]
]

{ #category : #initialization }
GtLepiterDatabaseSnapshot >> initializeFromDatabase: aDatabase [ 
	self databaseUuid: aDatabase uuid.
	self databaseName: aDatabase databaseName.
	self localRootRelativePath: (RelativePath 
		with: aDatabase localStoreRootDirectory basename).
	
	self attachmentSnapshots: ((aDatabase attachmentDirectories 
		collect: [ :anAttachmentDirectory | 
			GtLepiterAttachmentSnapshot fromDirectory: anAttachmentDirectory ])).
	self pageSnapshots: (aDatabase pages collect: [ :aPage | 
		GtLepiterPageSnapshot fromPage: aPage ]).	
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> linksSnapshot [

	^ linksSnapshot
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> linksSnapshot: anObject [

	linksSnapshot := anObject
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> localRootRelativePath [
	^ localRootRelativePath
]

{ #category : #initialization }
GtLepiterDatabaseSnapshot >> localRootRelativePath: aPath [
	localRootRelativePath := aPath 
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> pageSnapshots [
	^ pageSnapshots
]

{ #category : #accessing }
GtLepiterDatabaseSnapshot >> pageSnapshots: aCollection [
	pageSnapshots := aCollection
]

{ #category : #printing }
GtLepiterDatabaseSnapshot >> printOn: aStream [
	super printOn: aStream.
	aStream 
		<< '(';
		<< self databaseName;
		<< ', ';
		<< self databaseUuid asString36;
		<< ')'
]
