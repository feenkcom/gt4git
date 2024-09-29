Extension { #name : #PureGitFile }

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'File operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | 
			BrGlamorousSimpleContextMenuContent new
				items: (Array streamContents: [ :actions |
					(self isTracked not or: [ self isModifiedInWorkTree ]) ifTrue: [
						actions nextPut: 'Stage' -> [ :e |
							self stage.
							e fireEvent: BrDropdownHideWish new ] ].
					self isStaged ifTrue: [
						actions nextPut: 'Unstage' -> [ :e |
							self unstage.
							e fireEvent: BrDropdownHideWish new ] ].
					actions nextPut: 'Analyze history over time' -> [ :e | 
						e phlow spawnObject: self analyze.
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Delete' -> [ :e | 
						self delete.
						e fireEvent: BrDropdownHideWish new ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtContentsFor: composite [
	<gtView>
	| text |
	[ text := self fileReference contents ] 
		on: ZnCharacterEncodingError 
		do: [ ^ composite empty ].
	^ composite textEditor
		title: 'Contents';
		priority: 30;
		tooltip: 'Current contents in work tree on file system';
		glamorousCodeFontAndSize;
		text: [ text ]
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'basename' . self basename }.
		{ 'parent' . self parent path . self parent }.
		{ 'status' . self status statusSummary . self status }.
		{ 'tracked' . self isTracked }.
		{ 'staged' . self isStaged }.
		{ 'modified in worktree' . self isModifiedInWorkTree }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitFile >> gtEditorFor: composite [
	<gtView>
	| text |
	[ text := self fileReference contents ] 
		on: ZnCharacterEncodingError 
		do: [ ^ composite empty ].
	^ composite forward
		title: 'Editor';
		priority: 35;
		tooltip: 'Edit current contents in work tree on file system';
		object: [ self fileReference ];
		view: #gtContentsFor:
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
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]
