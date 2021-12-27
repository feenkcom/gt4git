Class {
	#name : #GtLepiterLocalAttachmentChange,
	#superclass : #GtLepiterLocalChange,
	#instVars : [
		'uuidString',
		'propertiesChange',
		'fileChanges',
		'path'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #adding }
GtLepiterLocalAttachmentChange >> addFileChange: aFileChange [
	self fileChanges add: aFileChange
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> fileChanges [

	^ fileChanges ifNil: [
		fileChanges := OrderedCollection new ]
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> fileChanges: anObject [

	fileChanges := anObject
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> path [

	^ path
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> path: anObject [

	path := anObject
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> propertiesChange [

	^ propertiesChange
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> propertiesChange: anObject [

	propertiesChange := anObject
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> uuidString [

	^ uuidString
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> uuidString: anObject [

	uuidString := anObject
]
