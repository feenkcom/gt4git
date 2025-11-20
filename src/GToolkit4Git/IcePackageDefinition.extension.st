Extension { #name : #IcePackageDefinition }

{ #category : #'*GToolkit4Git' }
IcePackageDefinition >> toolIn: aRepository [
	^ GtPackageCoderTool forPackage: (self packageOrganizer packageNamed: name)
]
