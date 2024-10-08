Extension { #name : #PureGitFileStatus }

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtActionGitFileFor: composite [
	<gtAction>
	^ composite button
		icon: BrGlamorousIcons file;
		tooltip: 'Open as git file';
		priority: 30;
		action: [ :element | element phlow spawnObject: self gitFile ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'File operations';
		icon: BrGlamorousVectorIcons hamburger;
		priority: 20;
		content: [ :aButton | | gitFile |
			gitFile := self gitFile.
			BrGlamorousSimpleContextMenuContent new
				items: (Array streamContents: [ :actions |
					(gitFile isTracked not or: [ gitFile isModifiedInWorkTree ]) ifTrue: [
						actions nextPut: 'Stage' -> [ :e |
							gitFile stage.
							e fireEvent: BrDropdownHideWish new ] ].
					gitFile isStaged ifTrue: [
						actions nextPut: 'Unstage' -> [ :e |
							gitFile unstage.
							e fireEvent: BrDropdownHideWish new ] ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'original path' . self originalPath ifNil: [ '' ] . self originalPath }.
		{ 'status in index' . self statusInIndex }.
		{ 'status in work tree' . self statusInWorkTree }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtStagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Staged';
		priority: 30;
		tooltip: 'Changes added to index for next commit';
		text: [ self stagedChangesAsRopedText ];
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self stagedChanges ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtUnstagedChangesFor: composite [
	<gtView>
	^ composite textEditor
		title: 'Unstaged';
		priority: 35;
		tooltip: 'Changes made after file was added to index';
		text: [ self unstagedChangesAsRopedText ];
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self unstagedChanges ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> stagedChangesAsRopedText [
	^ self repository diffTool
		diffArgs: { '--staged' . self path };
		asRopedText
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> unstagedChangesAsRopedText [
	^ self repository diffTool
		diffArgs: { self path };
		asRopedText
]
