Extension { #name : #IceGitCliIndex }

{ #category : #'*GToolkit4Git' }
IceGitCliIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]
