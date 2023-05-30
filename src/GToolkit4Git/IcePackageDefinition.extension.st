Extension { #name : #IcePackageDefinition }

{ #category : #'*GToolkit4Git' }
IcePackageDefinition >> toolIn: aRepository [
	^ GtPackageCoderTool package: (RPackage organizer packageNamed: name)
]
