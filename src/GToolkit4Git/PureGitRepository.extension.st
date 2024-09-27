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
					self exists
						ifTrue: [
							actions nextPut: 'Delete' -> [ :e | 
								self delete.
								e fireEvent: BrDropdownHideWish new ] ] 
						ifFalse: [
							actions nextPut: 'Init' -> [ :e | 
								self init.
								e fireEvent: BrDropdownHideWish new ] ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtBranchesFor: composite [
	<gtView>
	| currentBranchName currentBranchNameThunk |
	currentBranchName := nil.
	currentBranchNameThunk := [ currentBranchName ifNil: [
		currentBranchName := self currentBranchName ] ].
	^ composite columnedList
		title: 'Branches';
		priority: 35;
		items: [ self allBranches ];
		column: 'Name' text: #name;
		column: 'Type' text: #branchType;
		column: 'Commit' text: #shortCommitId;
		column: 'Current' 
			icon: [ :branch | 
				(branch name = currentBranchNameThunk value 
					or: [ currentBranchNameThunk value isEmpty
						and: [ branch name includesSubstring: 'HEAD detached' ] ])
					ifTrue: [ BrGlamorousIcons greencircle ]
					ifFalse: [ BrGlamorousIcons empty ] ]
			width: 75;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
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
			head := self head.
			branch := self branch.
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
	| fileStatuses fileStatusesThunk |
	self exists ifFalse: [ ^ composite empty ].
	fileStatuses := nil.
	fileStatusesThunk := [ fileStatuses
			ifNil: [ fileStatuses := Dictionary new.
				self status do: [ :each | fileStatuses at: each path put: each ].
				fileStatuses ] ].
	^ (self location gtTreeFor: composite)
		title: 'Files';
		priority: 45;
		column: 'Tracked'
			icon: [ :each | 
				| relative |
				relative := (each relativeTo: self location) pathString.
				(fileStatusesThunk value includesKey: relative)
					ifTrue: [ (fileStatusesThunk value at: relative) statusInIndex = #unknown
							ifTrue: [ BrGlamorousIcons close ]
							ifFalse: [ BrGlamorousIcons accept ] ]
					ifFalse: [ each isDirectory
							ifTrue: [ BrGlamorousIcons empty ]
							ifFalse: [ BrGlamorousIcons accept ] ] ]
			width: 100;
		contextItemLabel: 'Inspect file in repository'
			action: [ :element :item | 
				BlTaskAction
					enqueueElement: element
					action: [ element phlow
						spawnObject: (self resolveFileReference: item value) ] ];
		contextItemLabel: 'Inspect file reference'
			action: [ :element :item | 
				BlTaskAction
					enqueueElement: element
					action: [ element phlow spawnObject: item value ] ];
		send: [ :each | self resolveFileReference: each value ]
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
			commits := self allAnnotatedCommits.
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
	^ composite forward
		title: 'Internals';
		priority: 80;
		object: [ self internals ];
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		view: #gtItemsFor:
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtLogFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self log ];
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
		items: [ self remotes ];
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
		actionButtonIcon: BrGlamorousVectorIcons changes
			tooltip: 'Unified diff' 
			action: [ :aButton | aButton phlow spawnObject: self stagedChanges ];
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
					(fileStatuses := self status)
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
		items: [ self tags ];
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
			action: [ :aButton | aButton phlow spawnObject: self stagedChanges ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository class >> gtViewGitCallsIn: composite [
	<gtClassView>
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ 
			( ( ((#runGitWithArgs: gtReferences
						| #runGitWithArgsAsync: gtReferences) 
					& #gtViewGitCallsIn: gtImplementors not)
						& 'PureGitRepository' gtClassMatches) contents
				, 
				{ self >> #contentsOfBlob: } )
					 sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
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
