Class {
	#name : #GtLepiterAttachmentSnapshot,
	#superclass : #GtLepiterSnapshot,
	#instVars : [
		'attachmentUuid',
		'propertiesContents',
		'fileSnapshots'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'instance creation' }
GtLepiterAttachmentSnapshot class >> fromDirectory: aDirectory [
	^ self new
		initializeFromDirectory: aDirectory
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> attachmentUuid [

	^ attachmentUuid
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> attachmentUuid: anObject [

	attachmentUuid := anObject
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> fileSnapshots [

	^ fileSnapshots
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> fileSnapshots: anObject [

	fileSnapshots := anObject
]

{ #category : #initialization }
GtLepiterAttachmentSnapshot >> initializeFromDirectory: aDirectory [
	| targetFiles |
	self attachmentUuid: (UUID fromString36: aDirectory basename).
	self propertiesContents: (aDirectory / LeAttachment basename) contents. 
	
	targetFiles := aDirectory files select: [ :aFile | 
			aFile basename ~= LeAttachment basename ].
	self fileSnapshots: (targetFiles collect: [ :aFile |
		GtLepiterAttachmentFileSnapshot fromFile: aFile ])
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> propertiesContents [

	^ propertiesContents
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> propertiesContents: anObject [

	propertiesContents := anObject
]

{ #category : #accessing }
GtLepiterAttachmentSnapshot >> propertiesFileName [
	^ LeAttachment basename
]
