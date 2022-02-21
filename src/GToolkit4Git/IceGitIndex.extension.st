Extension { #name : #IceGitIndex }

{ #category : #'*GToolkit4Git' }
IceGitIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]

{ #category : #'*GToolkit4Git' }
IceGitIndex >> removeDirectoryFromIndex: aString [
	self repositoryHandle index removeDirectory: aString
]

{ #category : #'*GToolkit4Git' }
IceGitIndex >> removeFileFromIndex: aString [
	self repositoryHandle index remove: aString
]
