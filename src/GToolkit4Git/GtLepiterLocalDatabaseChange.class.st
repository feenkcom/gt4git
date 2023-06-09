Class {
	#name : #GtLepiterLocalDatabaseChange,
	#superclass : #GtLepiterLocalChange,
	#instVars : [
		'database',
		'propertiesFileChange',
		'pageChanges',
		'attachmentChanges',
		'linksChange'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterLocalDatabaseChange >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabaseChange: self
]

{ #category : #adding }
GtLepiterLocalDatabaseChange >> addAttachmentChange: anAttachmentChange [
	self attachmentChanges add: anAttachmentChange
]

{ #category : #adding }
GtLepiterLocalDatabaseChange >> addPageChange: aPageChange [
	self pageChanges add: aPageChange
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> attachmentChanges [

	^ attachmentChanges
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
GtLepiterLocalDatabaseChange >> databaseName [
	^ self database databaseName
]

{ #category : #accessing }
GtLepiterLocalDatabaseChange >> databaseUuid [
	^ self database uuid
]

{ #category : #initialization }
GtLepiterLocalDatabaseChange >> initialize [
	super initialize.
	attachmentChanges := OrderedCollection new.
	pageChanges := OrderedCollection new.
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> linksChange [

	^ linksChange
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> linksChange: anObject [

	linksChange := anObject
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> pageChanges [

	^ pageChanges
]

{ #category : #printing }
GtLepiterLocalDatabaseChange >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self databaseName;
		<< ')' 	
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> propertiesFileChange [

	^ propertiesFileChange
]

{ #category : #'accessing changes' }
GtLepiterLocalDatabaseChange >> propertiesFileChange: anObject [

	propertiesFileChange := anObject
]
