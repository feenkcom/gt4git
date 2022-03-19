Extension { #name : #IceFileSystemDefinition }

{ #category : #'*GToolkit4Git' }
IceFileSystemDefinition >> toolIn: aRepository [
	^ GtInspectorTool forObject: (aRepository repository repositoryDirectory absolutePath / self path pathString) asFileReference  
]
