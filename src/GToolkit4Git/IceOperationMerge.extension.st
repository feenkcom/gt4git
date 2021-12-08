Extension { #name : #IceOperationMerge }

{ #category : #'*GToolkit4Git' }
IceOperationMerge >> gtViewDiffFor: aView [
	<gtView>
	^ aView forward
		title: 'Diff';
		priority: 20;
		object: [ self chosenOperation ];
		view: #gtViewDiffFor:
]
