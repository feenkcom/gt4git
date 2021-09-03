Extension { #name : 'IceNode' }

{ #category : '*GToolkit4Git' }
IceNode >> gtViewDiffFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Diff' translated;
		priority: 20;
		text: [ :anEditor | 
			GtEpiceaDiffStencil new
				from: self value rightContents;
				to: self value leftContents;
				create ]
]
