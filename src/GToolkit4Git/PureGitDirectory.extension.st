Extension { #name : #PureGitDirectory }

{ #category : #'*GToolkit4Git' }
PureGitDirectory >> gtDetails [
	^ super gtDetails , {
		{ 'path' . self path . self fileReference }.
		{ 'basename' . self basename }.
		{ 'parent' . self parent path . self parent }.
		{ 'root' . self isRoot gtColoredText . self isRoot }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitDirectory >> gtFilesFor: composite [
	<gtView>
	^ composite columnedTree
		title: 'Files';
		priority: 45;
		items: [ Array with: self ];
		children: #children;
		column: 'Path'
			text: [ :each | each basename ifEmpty: [ self repository location ] ]
			weight: 2.0;
		column: 'Size'
			text: [ :each |
				each isDirectory
					ifTrue: [ '' ]
					ifFalse: [ 
						[ each size humanReadableSISizeString ]
							on: FileException, FileSystemError
							do: [ :anException | anException return: '' ] ] ]
			weight: 0.25;
		column: 'Created'
			text: [  :each |
				[ each creationTime printToSeconds ]
					on: FileException, FileSystemError
					do: [ :anException | anException return: '' ] ]
			weight: 0.5;
		column: 'Tracked'
			icon: [ :each | 
				each isDirectory
					ifTrue: [ BrGlamorousVectorIcons transparent ]
					ifFalse: [ each isTracked
						ifTrue: [ BrGlamorousVectorIcons accept ]
						ifFalse: [ BrGlamorousVectorIcons close ] ] ]
			weight: 0.25;
		column: 'Status index'
			text: [ :each | (each isDirectory or: [ each status statusInIndex = #unmodified ])
				ifTrue: [ '' ]
				ifFalse: [ each status statusInIndex ] ]
			weight: 0.5;
		column: 'Status worktree'
			text: [ :each | (each isDirectory or: [ each status statusInWorkTree = #unmodified ]) 
				ifTrue: [ '' ] 
				ifFalse: [ each status statusInWorkTree ] ]
			weight: 0.5;
		contextItemLabel: 'Inspect file'
			action: [ :element :each | element phlow spawnObject: each value ];
		contextItemLabel: 'Inspect status'
			action: [ :element :each | element phlow spawnObject: each value status ];
		contextItemLabel: 'Stage'
			action: [ :element :each | element phlow spawnObject: each value stage ]
			if: [ :each | each value canBeStaged ];
		contextItemLabel: 'Unstage'
			action: [ :element :each | element phlow spawnObject: each value unstage ]
			if: [ :each | each value isStaged ];
		contextItemLabel: 'Restore'
			action: [ :element :each | element phlow spawnObject: each value restore ]
			if: [ :each | each value canBeRestored ];
		contextItemLabel: 'Delete'
			action: [ :element :each | element phlow spawnObject: each value delete ];
		updateWhen: PureGitRepositoryModified in: [ self repository announcer ];
		actionUpdateButton;
		actionStencil: [ :aTab | | aptitude |
			aptitude := BrGlamorousWithExplicitDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Create new file' ]
				content: [ | fileCreationPane |
					fileCreationPane := GtGitFileCreationPane new.
					fileCreationPane
						acceptAction: [ :aModel :aButton | | filename |
							filename := fileCreationPane filename.
							(self fileReference / filename) ensureCreateFile.
							self repository announceRepositoryModified.
							aButton enqueueTask: (BlTaskAction new 
								action: [ aTab viewContentElement phlow update.
									aButton fireEvent: BrDropdownHideWish new]) ];
						cancelAction: [ :aModel :aButton |
							aButton enqueueTask: (BlTaskAction new 
								action: [ aButton fireEvent: BrDropdownHideWish new ]) ].
					fileCreationPane asElement ].			
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude + aptitude;
				icon: BrGlamorousVectorIcons add;
				label: 'Create new file' ];
		expandOneLevel
]

{ #category : #'*GToolkit4Git' }
PureGitDirectory >> gtLogFor: composite [
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
