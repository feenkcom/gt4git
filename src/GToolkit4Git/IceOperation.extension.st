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
IceOperation >> gtViewTwoPanesDiffFor: aView [
	<gtView>
	^ aView explicit
		title: 'Diff (two panes)';
		priority: 19;
		stencil: [ GtDiffElementWithLabelStencil new
				fromLabelText: 'Repository:';
				toLabelText: 'Working Copy (local):';
				change: (self definition class
						gtDiffChangeFrom: self rightContents
						to: self leftContents);
				styler: self definition class gtStyler ];
		yourself
]

{ #category : #'*GToolkit4Git' }
IceOperation >> tool [
	^ self leftDefinition tool
]
