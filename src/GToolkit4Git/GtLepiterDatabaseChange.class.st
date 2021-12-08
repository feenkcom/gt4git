Class {
	#name : #GtLepiterDatabaseChange,
	#superclass : #IceChange,
	#instVars : [
		'database'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterDatabaseChange >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabaseChange: self
]

{ #category : #accessing }
GtLepiterDatabaseChange >> database [
	^ database
]

{ #category : #accessing }
GtLepiterDatabaseChange >> database: aDatabase [
	database := aDatabase
]

{ #category : #accessing }
GtLepiterDatabaseChange >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self database databaseName;
		<< ')' 	
]
