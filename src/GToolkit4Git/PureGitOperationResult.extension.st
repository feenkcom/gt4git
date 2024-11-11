Extension { #name : #PureGitOperationResult }

{ #category : #'*GToolkit4Git' }
PureGitOperationResult >> gtDescriptionFor: composite [
	<gtView>
	^ composite text
		title: 'Description';
		priority: 10;
		text: self description
]

{ #category : #'*GToolkit4Git' }
PureGitOperationResult >> gtDetails [
	^ super gtDetails , {
		{ 'operation' . self operation }.
		{ 'args' . self args }.
		{ 'result' . self result }.
		{ 'duration' . self duration }.
	}
]
