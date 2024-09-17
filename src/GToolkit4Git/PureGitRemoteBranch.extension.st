Extension { #name : #PureGitRemoteBranch }

{ #category : #'*GToolkit4Git' }
PureGitRemoteBranch >> gtDetails [
	^ super gtDetails , {
		{ 'remote' . self remoteName . self remote }
	}
]
