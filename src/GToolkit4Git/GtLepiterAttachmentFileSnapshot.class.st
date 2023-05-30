Class {
	#name : #GtLepiterAttachmentFileSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'fileName',
		'binaryContents'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance creation' }
GtLepiterAttachmentFileSnapshot class >> fromFile: aFileReference [
	^ self new
		initializeFromFile: aFileReference
]

{ #category : #accessing }
GtLepiterAttachmentFileSnapshot >> binaryContents [

	^ binaryContents
]

{ #category : #accessing }
GtLepiterAttachmentFileSnapshot >> binaryContents: anObject [

	binaryContents := anObject
]

{ #category : #accessing }
GtLepiterAttachmentFileSnapshot >> fileName [

	^ fileName
]

{ #category : #accessing }
GtLepiterAttachmentFileSnapshot >> fileName: anObject [

	fileName := anObject
]

{ #category : #initialization }
GtLepiterAttachmentFileSnapshot >> initializeFromFile: aFileReference [
	self fileName: aFileReference basename.
	self binaryContents: aFileReference gtBinaryContents.
]
