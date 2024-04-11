Extension { #name : #IceNode }

{ #category : #'*GToolkit4Git' }
IceNode >> gtBrowseActionFor: anAction [
	<gtAction>
	self value definition needsRepositoryForTool ifTrue: [ ^ anAction noAction ].

	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons emphasizedBrowse;
		tooltip: 'Browse current version';
		action: [ :aButton | aButton phlow spawnTool: (self value definition toolIn: nil) ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtResolveConflictActionForView: aView [

	aView
		actionDropdownButtonLabel: 'Resolve'
		tooltip: 'Resolve Conflict'
		content: [ :aDropdown :aTarget | 
			| leftButton rightButton |
			leftButton := BrButton new.
			leftButton
				aptitude: BrGlamorousButtonWithLabelAptitude;
				label: 'Choose Repository';
				disabled: self value isRightChosen;
				margin: (BlInsets right: 5);
				action: [ 
					self value selectRight.
					Iceberg announcer announce: GtIceMergeConflictResolved new.
					aDropdown enqueueTask: (BlTaskAction new action: [ 
									 aDropdown dispatchEvent:
											 (BrDropdownHideWish new anchor: aDropdown) ]).
					rightButton phlow fireToolUpdateWish ].

			rightButton := BrButton new.
			rightButton
				aptitude: BrGlamorousButtonWithLabelAptitude;
				label: 'Choose Local';
				disabled: self value isLeftChosen;
				action: [ 
					self value selectLeft.
					Iceberg announcer announce: GtIceMergeConflictResolved new.
					aDropdown enqueueTask: (BlTaskAction new action: [ 
									 aDropdown dispatchEvent:
											 (BrDropdownHideWish new anchor: aDropdown) ]).
					rightButton phlow fireToolUpdateWish ].

			BrHorizontalPane new
				hFitContent;
				vFitContentLimited;
				padding: (BlInsets all: 10);
				addChildren: { 
						leftButton.
						rightButton } ] 
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewChildrenFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Children';
		priority: 50;
		items: [ self children ];
		column: 'Node' text: [ :aNode | aNode gtDisplayString ];
		column: 'Value' text: [ :aNode | aNode value gtDisplayString ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewDiffFor: aView [
	<gtView>
	
	((self value isKindOf: IceOperation) or: [ 
		 self value isKindOf: IceOperationMerge ]) ifFalse: [ ^ aView empty ].

	^ aView textEditor
		title: 'Diff' translated;
		priority: 20;
		text: [ :anEditor | 
			GtEpiceaDiffStencil new
				from: self value rightContents;
				to: self value leftContents;
				create ];
		in: [ :currentView | 
			self value isConflict ifTrue: [ 
				self gtResolveConflictActionForView: currentView ] ];
		yourself
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewNodeValuesTreeFor: aView [
	<gtView>
	
	^ aView tree
		title: 'Node values';
		priority: 25;
		items: [ { self } ];
		children: [ :each | each children ];
		itemText: [ :aNode | aNode value gtDisplayString ];
		expandAll;
		send: [ :aNode | aNode value ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewNodesTreeFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Nodes';
		items: [ { self } ];
		children: [ :each | each children ];
		column: 'Node' text: [ :aNode | aNode gtDisplayString ];
		column: 'Value' text: [ :aNode | aNode value gtDisplayString ];
		expandAll
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewTwoPanesDiffFor: aView [
	<gtView>
	^ aView explicit
		title: 'Diff (two panes)';
		priority: 19;
		stencil: [ GtDiffElementWithLabelStencil new
				fromLabelText: 'Repository:';
				toLabelText: 'Working Copy (local):';
				change: (self definition class
						gtDiffChangeFrom: self value rightContents
						to: self value leftContents);
				styler: self definition class gtStyler ];
		in: [ :currentView | 
			self value isConflict
				ifTrue: [ self gtResolveConflictActionForView: currentView ] ];
		yourself
]
