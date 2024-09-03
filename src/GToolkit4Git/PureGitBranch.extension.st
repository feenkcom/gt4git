Extension { #name : #PureGitBranch }

{ #category : #'*GToolkit4Git' }
PureGitBranch >> gtDetails [
	^ super gtDetails , {
		{ 'branch name' . self name ifNil: [ '' ] . self name }.
		{ 'branch type' . self branchType }.
		{ 'commit' . self commitId . self commit }
	}
]
