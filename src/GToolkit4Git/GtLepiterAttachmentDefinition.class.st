Class {
	#name : #GtLepiterAttachmentDefinition,
	#superclass : #GtLepiterDefinition,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterAttachmentDefinition >> icon [
	^ self iconNamed: #package
]
