Class {
	#name : #GtLepiterLocalDatabaseChange,
	#superclass : #IceChange,
	#instVars : [
		'database',
		'pages'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterLocalDatabaseChange >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabaseChange: self
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
