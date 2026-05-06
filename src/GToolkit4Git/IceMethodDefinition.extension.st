Extension { #name : #IceMethodDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> copyNameToClipboard [

	Clipboard clipboardText: self className asString, '>>#', self selector
]

{ #category : #'*GToolkit4Git' }
IceMethodDefinition class >> gtStyler [
	^ super gtStyler isForWorkspace: false
]

{ #category : #'*GToolkit4Git' }
IceMethodDefinition >> toolIn: aRepository [
	^ GtMethodCoderTool compiledMethod: (self contextClass methodNamed: name)
]
