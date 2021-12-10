Class {
	#name : #GtLepiterPropertiesFileDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'fileName',
		'fileContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #comparing }
GtLepiterPropertiesFileDefinition >> = anotherDefinition [

	^ super = anotherDefinition
		and: [ self fileName = anotherDefinition fileName 
			and: [ self fileContents = anotherDefinition fileContents ] ]
]

{ #category : #accessing }
GtLepiterPropertiesFileDefinition >> contents [ 
	^ self fileContents
]

{ #category : #accessing }
GtLepiterPropertiesFileDefinition >> fileContents [

	^ fileContents
]

{ #category : #accessing }
GtLepiterPropertiesFileDefinition >> fileContents: anObject [

	fileContents := anObject
]

{ #category : #accessing }
GtLepiterPropertiesFileDefinition >> fileName [

	^ fileName
]

{ #category : #accessing }
GtLepiterPropertiesFileDefinition >> fileName: anObject [

	fileName := anObject
]

{ #category : #comparing }
GtLepiterPropertiesFileDefinition >> hash [
	^ (super hash 
		bitXor: self fileName hash)
		bitXor: self fileContents hash
]
