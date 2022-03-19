Extension { #name : #IceOperation }

{ #category : #'*GToolkit4Git' }
IceOperation >> gtViewDiffFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Diff';
		priority: 20;
		text: [ :anEditor | 
			GtEpiceaDiffStencil new
				from: self rightContents;
				to: self leftContents;
				create ]
]

{ #category : #'*GToolkit4Git' }
IceOperation >> tool [
	^ self leftDefinition tool
]
