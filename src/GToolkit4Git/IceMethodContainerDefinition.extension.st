Extension { #name : #IceMethodContainerDefinition }

{ #category : #'*GToolkit4Git' }
IceMethodContainerDefinition >> toolIn: aRepository [

	^ GtClassCoderTool forClass: (Smalltalk globals at: name)
]
