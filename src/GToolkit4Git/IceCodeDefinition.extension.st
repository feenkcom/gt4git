Extension { #name : #IceCodeDefinition }

{ #category : #'*GToolkit4Git' }
IceCodeDefinition class >> gtDiffChangeFrom: aContent to: anotherContent [
	^ GtDiffBuilder
		computeDifferencesFrom: aContent
		to: anotherContent
		using: GtSmaCCDiffSplitter forPharo
]

{ #category : #'*GToolkit4Git' }
IceCodeDefinition class >> gtStyler [
	^ GtCodeDiffRBTextStyler new
		isForWorkspace: true;
		yourself
]
