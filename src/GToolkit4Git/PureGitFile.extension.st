Extension { #name : #PureGitFile }

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtActionGitFileFor: composite [
	<gtAction>
	^ composite button
		icon: BrGlamorousVectorIcons branching;
		tooltip: 'View git file status';
		priority: 30;
		action: [ :element | element phlow spawnObject: self status ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'File operations';
		icon: BrGlamorousVectorIcons hamburger;
		priority: 20;
		content: [ :aButton | BrGlamorousSimpleContextMenuContent new items: self gtOperations ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtAuthorsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Authors';
		priority: 50;
		tooltip: 'Authors who committed to ' , self path;
		items: [ self authors values sort: #numberOfCommits descending ];
		column: 'Name'
			stencil: [ :each | 
				BrLabel new
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new foreground: each color gtContrastingColor);
					text: each name;
					background: each color ];
		column: 'Number of commits'
			text: #numberOfCommits
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtBlameFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Blame';
		priority: 60;
		tooltip: 'Show last commit for each line of ' , self path;
		items: [ self blame ];
		column: '#'
			text: #lineNumber
			weight: 0.125;
		column: 'Commit'
			text: [ :blameLine | blameLine shortId ]
			weight: 0.165;
		column: 'Timestamp'
			text: [ :blameLine | (ZTimestampFormat fromString: '2001-02-03 16:05') format: blameLine timestamp ]
			weight: 0.33;
		column: 'Author'
			stencil: [ :blameLine | 
				| color |
				color := self colorForAuthor: blameLine author.
				BrLabel new
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new foreground: color gtContrastingColor);
					text: blameLine author;
					background: color ]
			weight: 0.5;
		column: 'Line'
			stencil: [ :blameLine | 
				BrLabel new
					aptitude: BrGlamorousLabelAptitude new editorMeasurement;
					text: blameLine line ]
			weight: 2.0
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'basename' . self basename }.
		{ 'parent' . self parent path . self parent }.
		{ 'exists' . self exists gtColoredText . self exists }.
		{ 'status' . self status statusSummary . self status }.
		{ 'tracked' . self isTracked gtColoredText . self isTracked }.
		{ 'clean' . self isClean gtColoredText . self isClean }.
		{ 'staged' . self isStaged gtColoredText . self isStaged }.
		{ 'modified in worktree' . self isModifiedInWorkTree gtColoredText . self isModifiedInWorkTree }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtEditorFor: composite [
	<gtView>
	| text |
	[ text := self contents ]
		on: ZnCharacterEncodingError
		do: [ ^ composite empty ].
	^ composite explicit
		title: 'Contents';
		priority: 30;
		tooltip: 'Current contents in work tree on file system';
		stencil: [ | pane |
			pane := self fileReference gtEditorView.
			pane
				childNamed: #editor
				ifFound: [ :editor | editor aptitude: BrGlamorousCodeEditorAptitude ].
			"sadly we cannot augment the shortcut primary S that easily"
			pane
				childNamed: #saveButton
				ifFound: [ :button | | action |
					action := button action.
					button
						action: [ :element :model :event | 
							self repository announceRepositoryModified.
							action cull: element cull: model cull: event ] ].
			pane ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtKumpelFor: aView [
	<gtView>
	^ aView forward
		title: 'Kumpel';
		object: [ self analyze ];
		view: #gtKumpelFor:
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtLogFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'History';
		priority: 40;
		tooltip: 'Commit log restricted to ' , self path;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author'
			stencil: [ :commit | 
				| color |
				color := self colorForAuthor: commit author.
				BrLabel new
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new foreground: color gtContrastingColor);
					text: commit author;
					background: color ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtOperations [
	^ Array
		streamContents: [ :actions | 
			actions
				nextPut: 'Status'
						-> [ :e | 
							e phlow spawnObject: self status.
							e fireEvent: BrDropdownHideWish new ].
			self canBeStaged
				ifTrue: [ actions
						nextPut: 'Stage'
								-> [ :e | 
									e phlow spawnObject: self stage.
									e fireEvent: BrDropdownHideWish new ] ].
			self isStaged
				ifTrue: [ actions
						nextPut: 'Unstage'
								-> [ :e | 
									e phlow spawnObject: self unstage.
									e fireEvent: BrDropdownHideWish new ] ].
			self canBeRestored
				ifTrue: [ actions
						nextPut: 'Restore'
								-> [ :e | 
									e phlow spawnObject: self restore.
									e fireEvent: BrDropdownHideWish new ] ].
			actions
				nextPut: 'Analyze history over time'
						-> [ :e | 
							e phlow spawnObject: self analyze.
							e fireEvent: BrDropdownHideWish new ].
			actions
				nextPut: 'Delete'
						-> [ :e | 
							e phlow spawnObject: self delete.
							e fireEvent: BrDropdownHideWish new ] ]
]
