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
				aptitude: (BrGlamorousWithExplicitContextMenuAptitude
						itemsWithAnchorActions: [ ({anIceNode value canBeBrowsed
											ifTrue: [ 'Browse'
													-> [ :e | e phlow spawnTool: (anIceNode value definition toolIn: self) ] ]
											ifFalse: [ nil ].
										'Revert changes' -> [ self revertChanges: anIceNode ]} reject: #isNil) ]);
				addChild: (anIceNode value icon asElement
						constraintsDo: [ :c | c linear vertical alignCenter ]);
				addChild: (BrLabel new
						text: anIceNode value name asString;
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
