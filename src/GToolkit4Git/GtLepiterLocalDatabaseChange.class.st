Class {
	#name : #GtLepiterLocalDatabaseChange,
	#superclass : #GtLepiterLocalChange,
	#instVars : [
		'database',
		'propertiesFile',
		'pages',
		'attachments',
		'links'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterLocalDatabaseChange >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabaseChange: self
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> addAttachment: anAttachmentChange [
	attachments add: anAttachmentChange
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> addPage: aPageChange [
	pages add: aPageChange
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> attachments [
	^ attachments
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> attachments: aList [
	attachments := aList
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> database [
	^ database
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> database: aDatabase [
	database := aDatabase
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> databaseUuid [
	^ self database uuid
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> hasChanges [

	^ self pages isEmpty not or: [ self attachments isEmpty not ]
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> initialize [
	super initialize.
	self attachments: OrderedCollection new.
	self pages: OrderedCollection new.
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> links [

	^ links
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> links: anObject [

	links := anObject
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> pages [
	^ pages
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> pages: aCollection [
	pages := aCollection
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self database databaseName;
		<< ')' 	
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> propertiesFile [

	^ propertiesFile
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> propertiesFile: anObject [

	propertiesFile := anObject
]
