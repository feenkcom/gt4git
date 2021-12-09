Class {
	#name : #GtLepiterDatabaseDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'databaseId'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId [

	^ databaseId
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId: anObject [

	databaseId := anObject
]

{ #category : #printing }
GtLepiterDatabaseDefinition >> printOn: aStream [
	super printOn: aStream.
	aStream 
		<< '(';
		<< self name;
		<< ', ';
		<< self databaseId asString36;
		<< ')'
]
