Extension { #name : #IceMethodDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> target [
	| owner |
	owner := Smalltalk globals at: self className.
	self classIsMeta
		ifTrue: [ owner := owner classSide ].
	^ owner >> name
]
