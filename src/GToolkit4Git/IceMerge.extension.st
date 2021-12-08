Extension { #name : #IceMerge }

{ #category : #'*GToolkit4Git' }
IceMerge >> gtInspectorMergeWindowIn: composite [
	<gtInspectorPresentationOrder:20>
	composite morph 
		title: 'Merge';
		display: [    
			|mergeMorph|
			 mergeMorph := (IceTipMergeMorph forMerger: self).
		    mergeMorph
		        fromDescription: self sourceDescription;
		        toDescription: self targetDescription.
			 mergeMorph ]
]

{ #category : #'*GToolkit4Git' }
IceMerge >> gtViewInspectorDiffFor: aView [
	<gtView>
	^ aView tree
		title: 'Changes';
		items: [ self treeToShow children ];
		children: #children;
		expandAll;
		stencil: [ :anIceNode | 
			BlElement new
				layout: BlLinearLayout horizontal;
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical fitContent ];
				margin: (BlInsets all: 3);
				constraintsDo: [ :c | c vertical fitContent ];
				"aptitude:
					(BrGlamorousWithContextMenuAptitude
						content: [ BrGlamorousSimpleContextMenuContent new
								display:
									{('Revert changes' -> [ self revertChanges: anIceNode ])};
								yourself ]);"
				addChild: ((anIceNode value icon asElement)
					constraintsDo: [ :c |
						c linear vertical alignCenter ]);
				addChild: (BrLabel new 
					text: anIceNode key asString;
					aptitude: BrGlamorousLabelAptitude;
					padding: (BlInsets top: 3 left: 6 bottom: 0 right: 3);
					constraintsDo: [ :c |
						c linear horizontal alignCenter ]) ]
					

		
]
