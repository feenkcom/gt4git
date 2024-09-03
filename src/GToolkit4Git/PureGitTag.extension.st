Extension { #name : #PureGitTag }

{ #category : #'*GToolkit4Git' }
PureGitTag >> gtDetails [
	^ super gtDetails , {
		{ 'tag name' . self name ifNil: [ '' ] . self name }.
		{ 'commit' . self commitId . self commit }
	}
]
