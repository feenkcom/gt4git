Extension { #name : #IceCodeDefinition }

{ #category : #'*GToolkit4Git' }
IceCodeDefinition class >> gtDiffBuilderFrom: aContent to: anotherContent [
	^ (GtCodeDiffBuilder 
		from: aContent 
		to: anotherContent) 
			isMethod: false
]
