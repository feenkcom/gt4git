Extension { #name : #IceDefinition }

{ #category : #'*GToolkit4Git' }
IceDefinition class >> gtDiffChangeFrom: aContent to: anotherContent [
	^ GtDiffBuilder
		computeDifferencesFrom: aContent
		to: anotherContent
		using: GtCharacterGroupDiffSplitter words
]

{ #category : #'*GToolkit4Git' }
IceDefinition class >> gtStyler [
	^ nil
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
