Class {
	#name : #GtLepiterDatabaseDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'databaseId',
		'localRootRelativePath'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtLepiterDatabaseDefinition >> accept: aVisitor [
	
	^ aVisitor visitLepiterDatabase: self
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId [

	^ databaseId
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> databaseId: anObject [

	databaseId := anObject
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> icon [
	^ LeIcons lepiterDatabase  create   asSpartaForm
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> localRootRelativePath [
	^ localRootRelativePath
]

{ #category : #accessing }
GtLepiterDatabaseDefinition >> localRootRelativePath: aPath [
	localRootRelativePath := aPath
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
