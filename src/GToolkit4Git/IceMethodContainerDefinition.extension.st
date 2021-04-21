Extension { #name : #IceMethodContainerDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodContainerDefinition >> target [
	| target |
	target := Smalltalk globals at: name.
	target isMeta ifTrue: [ target classSide ].
	^ target
]
