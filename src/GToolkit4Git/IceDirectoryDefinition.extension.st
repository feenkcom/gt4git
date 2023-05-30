Extension { #name : #IceDirectoryDefinition }

{ #category : #'*GToolkit4Git' }
IceDirectoryDefinition >> toolIn: aRepository [
	^ GtFileBrowserFolderTool forFolder: (aRepository repository repositoryDirectory absolutePath / self path pathString) asFileReference  
]
