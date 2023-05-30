Extension { #name : #IceLibgitCommitWalk }

{ #category : #'*GToolkit4Git' }
IceLibgitCommitWalk >> commitStream [
	^ self revwalk stream map: [:aCommit | self commitFrom: aCommit ]
]
