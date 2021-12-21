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
		  updateWhen: IceRepositoryModified in: Iceberg announcer;
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
				  aptitude: (BrGlamorousWithContextMenuAptitude content: [ 
							   BrGlamorousSimpleContextMenuContent new
								   items:
									   { ('Revert changes' -> [ self revertChanges: anIceNode ]) };
								   yourself ]);
				  addChild:
					  (anIceNode value icon asElement constraintsDo: [ :c | 
						   c linear vertical alignCenter ]);
				  addChild: (BrLabel new
						   text: anIceNode key asString;
						   aptitude: BrGlamorousLabelAptitude;
						   padding: (BlInsets
								    top: 3
								    left: 6
								    bottom: 0
								    right: 3);
						   constraintsDo: [ :c | c linear horizontal alignCenter ]) ]
]

{ #category : #'*GToolkit4Git' }
IceDiff >> revertChanges: aNode [
	self canRevertChanges ifTrue: [
		source discardChanges: aNode.
		Iceberg announcer announce: (IceRepositoryModified for: source repository)].
	
]
