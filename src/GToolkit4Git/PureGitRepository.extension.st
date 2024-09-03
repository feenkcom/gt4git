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
		column: 'Commit' text: [ :branch | branch commitId ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtDetails [
	| details |
	details := {
		{ 'location' . self location ifNil: [ 'not set' ] . self location }.
		{ 'exists' . self exists }
	}.
	self exists
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
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtHistoryFor: composite [
	<gtView>
	^ composite explicit
		title: 'History';
		tooltip: 'Don''s all commits view';
		priority: 31;
		stencil: [ | list color branches tags commits commitsMap ruler |
			branches := self allBranches.
			tags := self tags.
			commits := self allCommits.
			commitsMap := Dictionary new.
			commits do: [ :each | commitsMap at: each id put: each ].
			ruler := HiRulerBuilder
					newRulerValues: commits asOrderedCollection
					linksBlock: [ :commit | commit parentIds collect: [ :id | commitsMap at: id ] ].
			color := HiWheelColorStrategy new.
			color ruler: ruler.
			list := BrColumnedList new.
			list rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
			list column
				title: 'Graph';
				stencil: [ :_ :i | ruler gtElementForRow: i value withColorStrategy: color ];
				width: 100.
			list column
				title: 'Timestamp';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) timestamp ];
				width: 120.
			list column
				title: 'Refs';
				stencil: [ :_ :i | | labels each |
					each := commits at: i.
					labels := (tags select: [ :tag | tag commitId = each id ] thenCollect: #name) asOrderedCollection.
					labels addAll: (branches select: [ :branch | branch commitId = each id ] thenCollect: #name).
					BrTagger new
						aptitude: (BrGlamorousTaggerAptitude new
								tagLabel: ([ :aTag | 
									BrEditor new
										beReadOnlyWithoutSelection;
										aptitude: BrGlamorousEditableLabelAptitude new glamorousCodeTinySize;
										fitContent;
										text: aTag name ] asStencilBuilder: BrTaggerTagStencilBuilder));
						namedTags: labels ];
				width: 200.
			list column
				title: 'Commit';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) shortCommitId ];
				width: 70.
			list column
				title: 'Author';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) author ];
				width: 100.
			list column
				title: 'Message';
				weight: 1;
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) comment trimBoth firstLineWithEllipsis ].
			list
				when: BrSelectionDoubleClicked
				do: [ :anEvent | 
					anEvent selection
						ifNotEmpty: [ :theIndices | anEvent currentTarget phlow spawnObject: (commits at: theIndices first) ] ].
			list addAptitude: BrColumnedListHeaderAptitude.
			list items: (1 to: ruler numberOfRows).
			list ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtLogFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit id ];
		column: 'Timestamp' text: [ :commit | commit timestamp ];
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment ]
]

{ #category : #'*GToolkit4Git' }
PureGitRepository >> gtTagsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Tags';
		priority: 40;
		items: [ self tags ];
		column: 'Name' text: [ :tag | tag name ];
		column: 'Commit' text: [ :tag | tag commitId ]
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
