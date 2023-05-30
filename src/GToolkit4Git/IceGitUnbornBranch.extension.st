Extension { #name : #IceGitUnbornBranch }

{ #category : #'*GToolkit4Git' }
IceGitUnbornBranch >> treeFor: aRepository [
	^ (LGitTreeBuilder of: aRepository fromTree: nil) newTree
]
