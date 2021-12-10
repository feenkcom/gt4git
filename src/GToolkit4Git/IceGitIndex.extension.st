Extension { #name : #IceGitIndex }

{ #category : #'*GToolkit4Git' }
IceGitIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]
