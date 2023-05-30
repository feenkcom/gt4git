Class {
	#name : #GtLepiterAttachmentFileDefinition,
	#superclass : #GtLepiterDefinition,
	#instVars : [
		'fileName',
		'binaryContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #comparing }
GtLepiterAttachmentFileDefinition >> = anotherDefinition [

	^ super = anotherDefinition
		and: [ self fileName = anotherDefinition fileName 
			and: [ self binaryContents = anotherDefinition binaryContents ] ]
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> binaryContents [

	^ binaryContents
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> binaryContents: anObject [

	binaryContents := anObject
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> canBeBrowsed [
	^ false
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> contents [

	^ binaryContents
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> fileName [

	^ fileName
]

{ #category : #accessing }
GtLepiterAttachmentFileDefinition >> fileName: anObject [

	fileName := anObject
]

{ #category : #comparing }
GtLepiterAttachmentFileDefinition >> hash [
	^ (super hash 
		bitXor: self fileName hash)
		bitXor: self binaryContents hash
]

{ #category : #testing }
GtLepiterAttachmentFileDefinition >> isAttachmentFileDefinition [
	^ true
]
