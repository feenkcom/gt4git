Class {
	#name : #GtLepiterLocalDatabaseChange,
	#superclass : #IceChange,
	#instVars : [
		'database',
		'pages',
		'attachments'
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
