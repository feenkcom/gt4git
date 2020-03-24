Extension { #name : #IceDiff }

{ #category : #'*GToolkit4Git' }
IceDiff >> gtInspectorDiffIn: composite [
	<gtInspectorPresentationOrder:5>
	composite spec 
		display: [ (IceTipDiffPanel on: (IceTipCommitDiffModel on: self)) 
							buildWithSpec;
							yourself ];
		title: 'Diff'
]

{ #category : #'*GToolkit4Git' }
IceDiff >> gtViewInspectorDiffFor: aView [
	<gtView>
	^ aView tree
		title: 'Changes';
		items: [ self treeToShow children ];
		children: #children;
		itemStencil: [ :anIceNode | 
			BlElement new
				layout: BlLinearLayout horizontal;
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical fitContent ];
				margin: (BlInsets all: 3);
				constraintsDo: [ :c | c vertical fitContent ];
				addChild: ((anIceNode value icon asElement)
					constraintsDo: [ :c |
						c linear horizontal alignCenter ]);
				addChild: (BlTextElement new 
					text: anIceNode key asString asRopedText;
					padding: (BlInsets top: 3 left: 6 bottom: 0 right: 3);
					constraintsDo: [ :c |
						c linear horizontal alignCenter ]) ]
		
]
