Extension { #name : #LGitDeltaTypeEnum }

{ #category : #'*GToolkit4Git' }
LGitDeltaTypeEnum >> icon [

	^ { 
		  (1 -> self iconNamed: #changeAdd).
		  (2 -> self iconNamed: #changeRemove) } asOrderedCollection
		  at: self value
		  ifAbsent: [ self iconNamed: #changeUpdate ]
]
