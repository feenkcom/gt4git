Class {
	#name : #GtLepiterLocalAttachmentChange,
	#superclass : #IceChange,
	#instVars : [
		'uuidString',
		'propertiesChange',
		'fileChanges',
		'path',
		'delta'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> addFileChange: aFileChange [
	self fileChanges add: aFileChange
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> delta [

	^ delta
]

{ #category : #accessing }
GtLepiterLocalAttachmentChange >> delta: anObject [

	delta := anObject
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

{ #category : #testing }
GtLepiterLocalAttachmentChange >> isUntracked [
	^ self propertiesChange isNil and: [ 
		self fileChanges isEmpty ]
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
