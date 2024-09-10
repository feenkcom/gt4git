Extension { #name : #PureGitRepository }

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtBranchesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Branches';
		priority: 35;
		items: [ self allBranches ];
		column: 'Name' text: [ :branch | branch name ];
		column: 'Type' text: [ :branch | branch branchType ];
		column: 'Commit' text: [ :branch | branch commitId ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetails [
	| details |
	details := {
		{ 'location' . self location ifNil: [ 'not set' ] . self location }.
		{ 'exists' . self exists }
	}.
	self hasHead
		ifTrue: [
			details := details , {
				{ 'HEAD' . self head commitId . self head }
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
		actionUpdateButton
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
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtInternalsFor: composite [
	<gtView>
	^ composite forward
		title: 'Internals';
		priority: 50;
		object: [ self internals ];
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
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtStatusFor: composite [
	<gtView>
	| fileStatuses |
	self exists 
		ifFalse: [ ^ composite text
				title: 'Status';
				priority: 25;
				text: 'git repository does not exist' ].
	fileStatuses := self status.
	fileStatuses
		ifEmpty: [ ^ composite text
				title: 'Status';
				priority: 25;
				text: 'nothing to commit, working tree clean' ].
	^ composite columnedList
		title: 'Status';
		priority: 25;
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
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtTagsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Tags';
		priority: 40;
		items: [ self tags ];
		column: 'Name' text: [ :tag | tag name ];
		column: 'Commit' text: [ :tag | tag commitId ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitRepository class >> gtViewGitCallsIn: composite [
	<gtClassView>
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ 
			( ( (#runGitWithArgs: gtReferences & #gtViewGitCallsIn: gtImplementors not)
					& 'PureGitRepository' gtClassMatches) contents
				, 
				{ self >> #contentsOfBlob: } )
					 sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
]
