Extension { #name : #IceMethodDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodDefinition class >> gtDiffBuilderFrom: aContent to: anotherContent [
	^ (super gtDiffBuilderFrom: aContent to: anotherContent) 
			isMethod: true
]

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> toolIn: aRepository [
	^ GtMethodCoderTool compiledMethod: (self contextClass methodNamed: name)
]
