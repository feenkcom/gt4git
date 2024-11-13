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
		{ 'arg' . self arg }.
		{ 'result' . self result }.
		{ 'duration' . self duration }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitOperationResult >> gtRepositoryFor: composite [
	<gtAction>
	^ composite button
		icon: BrGlamorousVectorIcons branching;
		priority: 20;
		tooltip: 'Open repository';
		action: [ :element | element phlow spawnObject: self repository ]
]
