Extension { #name : #IceCommitish }

{ #category : #'*GToolkit4Git' }
IceCommitish >> commitStream [
	
	^ self newCommitWalk commitStream
]

{ #category : #'*GToolkit4Git' }
IceCommitish >> treeFor: aRepository [
	^ (aRepository revparse: self gitRef) tree
]
