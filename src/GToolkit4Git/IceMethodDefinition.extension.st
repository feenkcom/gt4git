Extension { #name : #IceMethodDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodDefinition class >> gtStyler [
	^ super gtStyler isForWorkspace: false
]

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> toolIn: aRepository [
	^ GtMethodCoderTool compiledMethod: (self contextClass methodNamed: name)
]
