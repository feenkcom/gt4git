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
		content: [ :aButton | BrGlamorousSimpleContextMenuContent new items: self gtOperations ]
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'original path' . self originalPath ifNil: [ '' ] . self originalPath }.
		{ 'status in index' . self statusInIndex }.
		{ 'status in work tree' . self statusInWorkTree }.
		{ 'tracked' . self isTracked }.
		{ 'clean' . self isClean }.
		{ 'staged' . self isStaged }.
		{ 'modified in worktree' . self isModifiedInWorkTree }.
		{ 'git file' . self path . self gitFile }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFileStatus >> gtOperations [
	| gitFile |
	gitFile := self gitFile.
	^ Array
		streamContents: [ :actions | 
			actions
				nextPut: 'File'
						-> [ :e | 
							e phlow spawnObject: gitFile.
							e fireEvent: BrDropdownHideWish new ].
			gitFile canBeStaged
				ifTrue: [ actions
						nextPut: 'Stage'
								-> [ :e | 
									e phlow spawnObject: gitFile stage.
									e fireEvent: BrDropdownHideWish new ] ].
			gitFile isStaged
				ifTrue: [ actions
						nextPut: 'Unstage'
								-> [ :e | 
									e phlow spawnObject: gitFile unstage.
									e fireEvent: BrDropdownHideWish new ] ].
			gitFile canBeRestored
				ifTrue: [ actions
						nextPut: 'Restore'
								-> [ :e | 
									e phlow spawnObject: gitFile restore.
									e fireEvent: BrDropdownHideWish new ] ].
			actions
				nextPut: 'Delete'
						-> [ :e | 
							e phlow spawnObject: gitFile delete.
							e fireEvent: BrDropdownHideWish new ] ]
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
