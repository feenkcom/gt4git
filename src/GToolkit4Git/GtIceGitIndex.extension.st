Extension { #name : #GtIceGitIndex }

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> removeDirectoryFromIndex: aString [
	#TODO
]

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> removeFileFromIndex: aString [
	#TODO
]
