Extension { #name : #PureGitFileCommit }

{ #category : #'*GToolkit4Git' }
PureGitFileCommit >> gtChangesFor: composite [
	<gtView>
	^ (super gtChangesFor: composite)
		tooltip: 'Diff to parent restricted to ', self path
]

{ #category : #'*GToolkit4Git' }
PureGitFileCommit >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path }
	}
]
