Extension { #name : #PureGitTree }

{ #category : #'*GToolkit4Git' }
PureGitTree >> gtDetails [
	^ super gtDetails , {
		{ 'tree' . self id }
	}
]
