Extension { #name : #PureGitTreeEntry }

{ #category : #'*GToolkit4Git' }
PureGitTreeEntry >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'type' . self type }.
		{ 'mode'
			. '{1} [{2}]' format: { self mode . self modeDescription } 
			. self mode }.
		{ 'id' . self id }
	}
]
