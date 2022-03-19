Extension { #name : #IceMethodDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> toolIn: aRepository [
	^ GtMethodCoderTool compiledMethod: (self contextClass methodNamed: name)
]
