Extension { #name : #IcePackageDefinition }

{ #category : #'*GToolkit4Git' }
IcePackageDefinition >> toolIn: aRepository [
	^ GtPackageCoderTool package: (self packageOrganizer packageNamed: name)
]
