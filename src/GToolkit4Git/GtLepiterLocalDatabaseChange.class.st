Class {
	#name : #GtLepiterLocalDatabaseChange,
	#superclass : #IceChange,
	#instVars : [
		'database'
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
GtLepiterLocalDatabaseChange >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self database databaseName;
		<< ')' 	
]
