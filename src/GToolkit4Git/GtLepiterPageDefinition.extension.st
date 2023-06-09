Extension { #name : #GtLepiterPageDefinition }

{ #category : #'*GToolkit4Git' }
GtLepiterPageDefinition class >> gtDiffChangeFrom: aContent to: anotherContent [
	^ GtDiffBuilder
		computeDifferencesFrom: aContent
		to: anotherContent
		using: GtSmaCCDiffSplitter forJSON
]

{ #category : #'*GToolkit4Git' }
GtLepiterPageDefinition class >> gtStyler [
	^ JSONParser gtStyler
]
