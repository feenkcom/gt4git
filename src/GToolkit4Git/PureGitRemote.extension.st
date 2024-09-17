Extension { #name : #PureGitRemote }

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'url' . self url }
	}
]
