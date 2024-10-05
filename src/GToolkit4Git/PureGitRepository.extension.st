Extension { #name : #PureGitRepository }

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Repository operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | 
			BrGlamorousSimpleContextMenuContent new
				items: (Array streamContents: [ :actions |
					actions nextPut: 'Pull' -> [ :e |
						self operations pull: #().
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Push' -> [ :e |
						self operations push: #().
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Fetch' -> [ :e |
						self operations fetch: #().
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Merge' -> [ :e |
						self operations merge: #().
						e fireEvent: BrDropdownHideWish new ].
					self exists
						ifTrue: [
							actions nextPut: 'Delete' -> [ :e | 
								self operations delete.
								e fireEvent: BrDropdownHideWish new ] ] 
						ifFalse: [
							actions nextPut: 'Init' -> [ :e | 
								self operations init.
								e fireEvent: BrDropdownHideWish new ] ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtBranchesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Branches';
		priority: 35;
		items: [ self queries allBranches ];
		column: 'Name' text: #name;
		column: 'Type' text: #branchType;
		column: 'Commit' text: #shortCommitId;
		column: 'Current' 
			icon: [ :branch | | currentBranchName |
				currentBranchName := self queries currentBranchName.
				(branch name = currentBranchName
					or: [ currentBranchName isEmpty
						and: [ branch name includesSubstring: 'HEAD detached' ] ])
					ifTrue: [ BrGlamorousIcons greencircle ]
					ifFalse: [ BrGlamorousIcons empty ] ]
			width: 75;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton;
		actionStencil: [ :aTab | | aptitude |
			aptitude := BrGlamorousWithDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Create new branch' ]
				content: [ | branchCreationPane |
					branchCreationPane := GtGitBranchCreationPane new.
					branchCreationPane
						acceptAction: [ :aModel :aButton | | branchName |
							branchName := branchCreationPane branchName.
							self 
								operations createBranch: branchName"; 
								configureUpstreamIfNecessary".
							aButton enqueueTask: (BlTaskAction new 
								action: [ aTab viewContentElement phlow update.
									aButton fireEvent: BrDropdownHideWish new]) ];
						cancelAction: [ :aModel :aButton |
							aButton enqueueTask: (BlTaskAction new 
								action: [ aButton fireEvent: BrDropdownHideWish new ]) ].
					branchCreationPane asElement ].			
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude + aptitude;
				icon: BrGlamorousVectorIcons add;
				label: 'Create new branch' ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetails [
	| details head branch |
	details := {
		{ 'location' . self location ifNil: [ 'not set' ] . self location }.
		{ 'exists' . self exists }
	}.
	self hasHead
		ifTrue: [
			head := self queries head.
			branch := self queries branch.
			details := details , {
				{ 'HEAD' . head shortCommitId . head }.
				{ 'branch' 
					. branch ifNil: [ 'HEAD detached' ] ifNotNil: [ branch name ]
					. branch }
			} ].
	^ details
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ self gtDetails ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtFilesFor: composite [
	<gtView>
	self exists ifFalse: [ ^ composite empty ].
	^ composite forward
		title: 'Files';
		priority: 45;
		object: [ self resolveDirectory ];
		view: #gtFilesFor:
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtHistoryFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite explicit
		title: 'History';
		tooltip: 'Don''s all commits view';
		priority: 31;
		stencil: [ | list color commits ruler |
			commits := self queries allAnnotatedCommits.
			ruler := HiRulerBuilder
					newRulerValues: commits
					linksBlock: [ :commit | commit parents ].
			color := HiWheelColorStrategy new.
			color ruler: ruler.
			list := BrColumnedList new.
			list rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
			list column
				title: 'Graph';
				stencil: [ :_ :i | ruler gtElementForRow: i value withColorStrategy: color ];
				weight: 0.5.
			list column
				title: 'Timestamp';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (timestampFormat format: (commits at: i) timestamp) ];
				weight: 0.5.
			list column
				title: 'Refs';
				stencil: [ :_ :i | 
					BrTagger new
						aptitude: (BrGlamorousTaggerAptitude new
								tagLabel: ([ :aTag | 
									BrEditor new
										beReadOnlyWithoutSelection;
										aptitude: BrGlamorousEditableLabelAptitude new glamorousCodeTinySize;
										fitContent;
										text: aTag name ] asStencilBuilder: BrTaggerTagStencilBuilder));
						namedTags: (commits at: i) labels ];
				weight: 1.
			list column
				title: 'Commit';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) shortId ];
				weight: 0.5.
			list column
				title: 'Author';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) author ];
				weight: 1.
			list column
				title: 'Comment';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) comment firstLineWithEllipsis ];
				weight: 2.
			list
				when: BrSelectionDoubleClicked
				do: [ :anEvent | 
					anEvent selection
						ifNotEmpty: [ :theIndices | anEvent currentTarget phlow spawnObject: (commits at: theIndices first) ] ].
			list addAptitude: BrColumnedListHeaderAptitude.
			list items: (1 to: ruler numberOfRows).
			list ];
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtInternalsFor: composite [
	<gtView>
	^ (self queries internals gtItemsFor: composite)
		title: 'Internals';
		priority: 80;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		expandAll
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtLogFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self queries log ];
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtRemotesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Remotes';
		priority: 37;
		items: [ self queries remotes ];
		column: 'name' text: #name;
		column: 'url' text: #url
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtStagedChangesFor: composite [
	<gtView>
	self exists ifFalse: [ ^ composite empty ].
	^ composite textEditor
		title: 'Staged';
		priority: 50;
		tooltip: 'Changes added to index for next commit';
		text: [ self stagedChangesAsRopedText ];
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionStencil: [ :aTab | | aptitude |
			aptitude := BrGlamorousWithDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons play;
						label: 'Commit staged changes' ]
				content: [ | commentCreationPane |
					commentCreationPane := GtGitCommentCreationPane new.
					commentCreationPane
						acceptAction: [ :aModel :aButton |
							self queries stagedChanges isEmpty
								ifFalse: [ self operations commit: commentCreationPane comment ].
							aButton enqueueTask: (BlTaskAction new 
								action: [ aTab viewContentElement phlow update.
									aButton fireEvent: BrDropdownHideWish new]) ];
						cancelAction: [ :aModel :aButton |
							aButton enqueueTask: (BlTaskAction new 
								action: [ aButton fireEvent: BrDropdownHideWish new ]) ].
					commentCreationPane asElement ].			
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude + aptitude;
				icon: BrGlamorousVectorIcons play;
				label: 'Commit staged changes' ];
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self queries stagedChanges ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtStatusFor: composite [
	<gtView>
	^ composite explicit
		title: 'Status';
		priority: 25;
		stencil: [
			self exists
				ifTrue: [ | fileStatuses |
					(fileStatuses := self queries status)
						ifNotEmpty: [
							composite columnedList
								items: [ fileStatuses ];
								column: 'Status in index' text: #statusInIndex weight: 0.5;
								column: 'Status in work tree' text: #statusInWorkTree weight: 0.5;
								column: 'Path' text: #path weight: 3]
						ifEmpty: [
							composite text text: 'nothing to commit, working tree clean' ]]
				ifFalse: [
					composite text text: 'git repository does not exist' ] ];
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtTagsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Tags';
		priority: 40;
		items: [ self queries tags ];
		column: 'Name' text: #name ;
		column: 'Commit' text: #shortCommitId;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtUnstagedChangesFor: composite [
	<gtView>
	self exists ifFalse: [ ^ composite empty ].
	^ composite textEditor
		title: 'Unstaged';
		priority: 55;
		tooltip: 'Changes made after files were added to index';
		text: [ self unstagedChangesAsRopedText ];
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self queries unstagedChanges ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> stagedChangesAsRopedText [
	^ self diffTool
		diffArgs: { '--staged' };
		asRopedText
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> unstagedChangesAsRopedText [
	^ self diffTool
		diffArgs: { };
		asRopedText
]
