Extension { #name : #IceOperationMerge }

{ #category : #'*GToolkit4Git' }
IceOperationMerge >> gtViewDiffFor: aView [
	<gtView>
	self chosenOperation ifNil: [ ^ aView empty ].
	
	^ aView forward
		title: 'Diff';
		priority: 20;
		object: [ self chosenOperation ];
		view: #gtViewDiffFor:
]
