Class {
	#name : #GtLepiterDefinition,
	#superclass : #IceDefinition,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterDefinition >> canBeBrowsed [
	^ false
]

{ #category : #accessing }
GtLepiterDefinition >> needsRepositoryForTool [
	^ true
]

{ #category : #accessing }
GtLepiterDefinition >> removeFrom: anObject [
	"noop"
]
