Extension { #name : #IceDefinition }

{ #category : #'*GToolkit4Git' }
IceDefinition class >> gtDiffBuilderFrom: aContent to: anotherContent [
	^ TextDiffBuilder 
		from:  aContent 
		to: anotherContent
]

{ #category : #'*GToolkit4Git' }
IceDefinition >> isAttachmentFileDefinition [
	^ false
]

{ #category : #'*GToolkit4Git' }
IceDefinition >> isAttachmentPropertiesDefinition [
	^ false
]

{ #category : #'*GToolkit4Git' }
IceDefinition >> needsRepositoryForTool [
	^ false
]
