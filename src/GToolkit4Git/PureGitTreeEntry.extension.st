Extension { #name : #PureGitTreeEntry }

{ #category : #'*GToolkit4Git' }
PureGitTreeEntry >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'type' . self type }.
		{ 'mode' . self mode }.
		{ 'id' . self id }
	}
]
