Extension { #name : #PureGitLocalBranch }

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtDetails [
	^ super gtDetails , {
		{ 'current' . self isCurrent }.
		{ 'upstream' 
			. self upstream ifNil: [ '' ] ifNotNil: [ :branch | branch name ]
			. self upstream }.
	} 
]
