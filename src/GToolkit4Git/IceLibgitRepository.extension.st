Extension { #name : #IceLibgitRepository }

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> executeCommit: aCommitMessage [
	|diff|
	diff := self workingCopyDiff.
	Iceberg announcer announce: (IceRepositoryModified for: self).
	self workingCopy 
		commitChanges: diff
		withMessage: aCommitMessage
		force: false.
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtActionFetchFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Fetch';
		action: [ 
			(IceTipRepositoryModel on: self) fetch.
				Iceberg announcer announce: (IceRepositoryModified for: self) ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtActionPullFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Pull';
		action: [ :aButton | 
			self pull.
			Iceberg announcer announce: (IceRepositoryModified for: self) ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtActionPushFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Push';
		action: [ :aButton | 
			self push.
			Iceberg announcer announce: (IceRepositoryModified for: self) ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtActionRefreshFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Refresh';
		action: [ 
		
			"Aim to only recalculate the dirty flag for packages that are marked as dirty.
			We skip packages that are not marked as dirty."

			| icebergRepository diff dirtyPackages |
			icebergRepository := self.
			icebergRepository isModified ifFalse: [ 
				"If the repository is not marked as modified no action is needed here"
				^ self ]. 

			"We compite the diff but only recalculate the status for dirty packages"
			diff := IceDiff new
				sourceVersion: icebergRepository workingCopy;
				targetVersion: icebergRepository workingCopy referenceCommit;
				buildFull.
		
			dirtyPackages:= icebergRepository loadedPackages 
				select: [ :each | each isDirty ].
			dirtyPackages do: [ :each |
				each beDirty: (diff includesPackageNamed: each name) ].
				Iceberg announcer announce: (IceRepositoryModified for: self)]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtLocalBranchesFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtLocalBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRemoteBranchesFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtRemoteBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView ].
	^ (self repositoryDirectory gtItemsFor: aView)
		title: 'Repository directory' translated;
		priority: 35
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtTagsFor: aView [
	self isMissing ifTrue: [ ^ aView ].
	^ super gtTagsFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtViewInspectorDiffFor: aView [
	<gtView>
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [
		((self workingCopy diffToReferenceCommit treeToShow children) size = 0) ifTrue: [aView] ifFalse:[
		aView tree
			title: 'Changes';
			items: [ self workingCopy diffToReferenceCommit treeToShow children ];
			updateWhen: IceRepositoryModified in: Iceberg announcer;
			children: #children;
			itemStencil: [ :anIceNode | 
				BlElement new
					layout: BlLinearLayout horizontal;
					constraintsDo: [ :c |
						c horizontal matchParent.
						c vertical fitContent ];
					margin: (BlInsets all: 3);
					constraintsDo: [ :c | c vertical fitContent ];
					look:
						(BrGlamorousWithContextMenuLook
							content: [ BrGlamorousSimpleContextMenuContent new
									display:
										{('Revert changes' -> [ :e | self workingCopy diffToReferenceCommit revertChanges: anIceNode ])};
									yourself ]);
					addChild: ((anIceNode value icon asElement)
						constraintsDo: [ :c |
							c linear horizontal alignCenter ]);
					addChild: (BlTextElement new 
						text: anIceNode key asString asRopedText;
						padding: (BlInsets top: 3 left: 6 bottom: 0 right: 3);
						constraintsDo: [ :c |
							c linear horizontal alignCenter ]) ];
							
				actionDropdownButtonIcon: nil 
					label: 'Commit...' 
					content: [ :b | 
									| editor button |
									editor := BrEditor new look: BrGlamorousCodeEditorLook.
									button := (BrButton new look: BrGlamorousButtonWithIconLook; icon: BrGlamorousIcons accept asElement; label: 'Commit...'; action: [
										self executeCommit:  (editor editor text asString).]).
									button disable.
									editor editor when: BrTextEditorModifiedEvent do: [ :anEvent | ((anEvent text asString) isEmpty) ifTrue: [button disable]; ifFalse: [button enable].  ].
									BlElement new
										constraintsDo: [:c | c horizontal exact: 400. c vertical fitContent];
										layout: BlLinearLayout vertical;
										padding: (BlInsets all: 10);
										addChild: editor;
										addChild: button]]]
						
						

		
]
