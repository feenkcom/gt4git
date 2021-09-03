Extension { #name : 'IceGitCommit' }

{ #category : '*GToolkit4Git' }
IceGitCommit >> gtChangesFor: aView [
	<gtView>
	^ (IceDiff from: self to:self parent) gtViewInspectorDiffFor: aView
]

{ #category : '*GToolkit4Git' }
IceGitCommit >> gtFileSystemItemsFor: aView [
	<gtView>
	^ (self fileSystem gtItemsFor: aView)
		title: 'File system' translated;
		priority: 70
]
