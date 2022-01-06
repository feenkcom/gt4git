Extension { #name : #IceCommitish }

{ #category : #'*GToolkit4Git' }
IceCommitish >> treeFor: aRepository [
	^ (aRepository revparse: self gitRef) tree
]
