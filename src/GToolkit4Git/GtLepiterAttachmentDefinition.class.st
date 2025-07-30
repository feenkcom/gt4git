Class {
	#name : #GtLepiterAttachmentDefinition,
	#superclass : #GtLepiterDefinition,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterAttachmentDefinition >> icon [
	^ self iconNamed: #package
]

{ #category : #accessing }
GtLepiterAttachmentDefinition >> iconName [
	"Used in Pharo 12 instead of #icon"
	^ #package
]
