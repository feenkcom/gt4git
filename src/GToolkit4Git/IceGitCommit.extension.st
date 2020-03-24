Extension { #name : #IceGitCommit }

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtFileSystemItemsFor: aView [
	<gtView>
	^ (self fileSystem gtItemsFor: aView)
		title: 'File system' translated;
		priority: 70
]
