Extension { #name : #PureGitRepository }

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Repository operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | BrGlamorousSimpleContextMenuContent new items: self gtOperations ]
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
							BlTaskAction 
								enqueueElement: aButton 
								action: [ 
									aTab phlow spawnObject: (self operations async createBranch: branchName).
									aButton fireEvent: BrDropdownHideWish new] ];
						cancelAction: [ :aModel :aButton |
							BlTaskAction 
								enqueueElement: aButton 
								action: [ aButton fireEvent: BrDropdownHideWish new ] ].
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
			list
				rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
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
									BrButton new
										aptitude: BrGlamorousButtonWithLabelAptitude new glamorousCodeTinySize;
										label: aTag name;
										action: [ :element | element phlow spawnObject: (self queries resolveBranchOrTag: aTag name) ] ]
										asStencilBuilder: BrTaggerTagStencilBuilder));
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
	^ composite explicit
		title: 'Internals';
		priority: 80;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		stencil: [ (self queries internals gtItemsFor: composite) expandAll ]
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
		actionStencil: [ :aButton | 
			GtSpotterDropdownButtonStencil new
				object: self;
				tooltip: 'Search commits';
				objectActOn: [ :anActOnEvent :anItem :theButton | | targetCommit |
					targetCommit := anActOnEvent objectToSend.
					(targetCommit isKindOf: PureGitCommit) 
						ifTrue: [ | columnedList |
							columnedList := theButton phlow viewContent 
								allChildrenBreadthFirstDetect: [ :child | 
									child isKindOf:  BrColumnedList ] 
								ifFound: [ :child | child ].
							columnedList scrollToItem: targetCommit.
							columnedList selectOne: (columnedList items indexOf: targetCommit) ].
					anActOnEvent beActed ];
				asElement ]
			tooltip: 'Search commits';
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtOperations [
	^ Array
		streamContents: [ :actions | 
			self exists
				ifTrue: [ actions
						nextPut: 'Pull'
								-> [ :e | 
									e phlow spawnObject: (self operations async pull: #()).
									e fireEvent: BrDropdownHideWish new ].
					actions
						nextPut: 'Push'
								-> [ :e | 
									e phlow spawnObject: (self operations async push: #()).
									e fireEvent: BrDropdownHideWish new ].
					actions
						nextPut: 'Fetch'
								-> [ :e | 
									e phlow spawnObject: (self operations async fetch: #()).
									e fireEvent: BrDropdownHideWish new ].
					actions
						nextPut: 'Merge'
								-> [ :e | 
									e phlow spawnObject: (self operations async merge: #()).
									e fireEvent: BrDropdownHideWish new ].
					actions
						nextPut: 'Code'
								-> [ :e | 
									e phlow spawnObject: (PureGitCodeRepository on: self location).
									e fireEvent: BrDropdownHideWish new ].
					actions
						nextPut: 'Statistics'
								-> [ :e | 
									e phlow spawnObject: (PureGitRepositoryStatistics inRepository: self).
									e fireEvent: BrDropdownHideWish new ] ]
				ifFalse: [ actions
						nextPut: 'Init'
								-> [ :e | 
									e phlow spawnObject: (self operations async init).
									e fireEvent: BrDropdownHideWish new ] ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtRemotesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Remotes';
		priority: 37;
		items: [ self queries remotes ];
		column: 'name' text: #name;
		column: 'url' text: #url;
		contextItemLabel: 'Inspect' action: [ :element :remote | element phlow spawnObject: remote ];
		contextItemLabel: 'Push' action: [ :element :remote | remote push ];
		contextItemLabel: 'Pull' action: [ :element :remote | remote pull ];
		contextItemLabel: 'Fetch' action: [ :element :remote | remote fetch ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtSearchCommitAuthorsFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Commit authors';
		priority: 55;
		items: [ self log ];
		itemName: [ :commit | commit author ];
		filterBySubstring
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtSearchCommitCommentsFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Commit comments';
		priority: 50;
		items: [ self log ];
		itemName: [ :commit | commit comment ];
		filterBySubstring
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
		stencil: [ self exists
				ifTrue: [ | fileStatuses |
					(fileStatuses := self queries status)
						ifNotEmpty: [ composite columnedList
								items: [ fileStatuses ];
								column: 'Status in index'
									text: #statusInIndex
									weight: 0.5;
								column: 'Status in work tree'
									text: #statusInWorkTree
									weight: 0.5;
								column: 'Path'
									text: #path
									weight: 3;
								contextItemLabel: 'Inspect status'
									action: [ :element :item | element phlow spawnObject: item ];
								contextItemLabel: 'Inspect file'
									action: [ :element :item | element phlow spawnObject: item value gitFile ];
								contextItemLabel: 'Stage'
									action: [ :element :item | element phlow spawnObject: item gitFile stage ]
									if: [ :item | item gitFile canBeStaged ];
								contextItemLabel: 'Unstage'
									action: [ :element :item | element phlow spawnObject: item gitFile unstage ]
									if: [ :item | item gitFile isStaged ];
								contextItemLabel: 'Restore'
									action: [ :element :item | element phlow spawnObject: item gitFile stage ]
									if: [ :item | item gitFile canBeRestored ];
								contextItemLabel: 'Delete'
									action: [ :element :item | element phlow spawnObject: item value gitFile delete ] ]
						ifEmpty: [ composite text text: 'nothing to commit, working tree clean' ] ]
				ifFalse: [ composite text text: 'git repository does not exist' ] ];
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
