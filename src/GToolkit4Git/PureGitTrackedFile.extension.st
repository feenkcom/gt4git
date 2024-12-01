Extension { #name : #PureGitTrackedFile }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> asCombinedGraphElement [
	| mainContainer maxChanged |
	(mainContainer := BlElement new)
		layout: (BlLinearLayout horizontal);
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical matchParent ].
	maxChanged := (self commits collect: #numberOfLinesChanged) max.
	self commits do: [ :extendedFileCommit | | commitContainer |
		(commitContainer := BlElement new)
			layout: (BlLinearLayout vertical  cellSpacing: 5);
			constraintsDo: [ :c |
				c horizontal fitContent.
				c vertical matchParent
				 ].
		commitContainer addChild: (self verticalChangeBarElementFor: extendedFileCommit normalized: maxChanged).
		commitContainer addChild: (self verticalOwnershipBarElementFor: extendedFileCommit).
		commitContainer addChild: (self verticalCommitLabelElementFor: extendedFileCommit).

		commitContainer when: BlClickEvent do: [ :e | e target phlow spawnObject: extendedFileCommit ].
		mainContainer addChild: commitContainer ].
	^ mainContainer
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> asKumpelGraphElement [
	| container |
	container := BlElement new.
	self uniqueTrackedLines do: [ :trackedLine | 
		| authorName author element |
		element := trackedLine asKumpelGraphElement.
		authorName := self authorOfTrackedLine: trackedLine.
		author := self authors at: authorName ifAbsent: [ nil ].
		element
			addAptitude: (BrStyleCommonAptitude new
					default: [ :s | 
						s background: (self colorForAuthor:  authorName).
						s border: (self colorForAuthor:  authorName) ];
					hovered: [ :s | 
						s background: (self contrastColorForAuthor: authorName) darker.
						s border: (self contrastColorForAuthor: authorName) darker ];
					pressed: [ :s | s background: (self contrastColorForAuthor: authorName) muchDarker ]).
		element
			addAptitude: (BrGlamorousWithContextMenuAptitude
					content: [ BrLabel new
							aptitude: BrGlamorousLabelAptitude;
							text: authorName ]).
		element
			when: BlClickEvent
			do: [ :e | e target phlow 
					spawnObject: (e modifiers isShift ifTrue: [ author ] ifFalse: [ trackedLine ]) ].
		container addChild: element ].
	container
		size: ((self versions size *  (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
					- PureGitTrackedLine versionMargin)
				@ (PureGitTrackedLine lineHeight * self maxLinesCount).
	^ container 
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> asSuperGraphElement [
	| container topContainer maxChanged bottomContainer |
	(container := BlElement new)
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ].
	maxChanged := (self commits collect: #numberOfLinesChanged) max.
	topContainer := BrHorizontalPane new fitContent.
	self commits
		do: [ :extendedFileCommit | 
			| commitContainer |
			commitContainer := BrVerticalPane new fitContent.
			commitContainer
				addChild: (self verticalChangeBarElementFor: extendedFileCommit normalized: maxChanged).
			commitContainer
				addChild: (self verticalCommitLabelElementFor: extendedFileCommit).
			commitContainer
				when: BlClickEvent
				do: [ :e | e target phlow spawnObject: extendedFileCommit ].
			topContainer addChild: commitContainer ].
	container addChild: topContainer.

	container addChild: self asKumpelGraphElement.
	container
		addChild: (self horizontalAuthorsElement margin: (BlInsets top: 5 bottom: 5)).

	bottomContainer := BrHorizontalPane new fitContent.
	self commits
		do: [ :extendedFileCommit | 
			| commitContainer |
			commitContainer := BrVerticalPane new fitContent.
			commitContainer
				addChild: (self verticalOwnershipBarElementFor: extendedFileCommit).
			commitContainer
				when: BlClickEvent
				do: [ :e | e target phlow spawnObject: extendedFileCommit ].
			bottomContainer addChild: commitContainer ].
	container addChild: bottomContainer.


	^ container
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'git file'
				. self file path
				. self file }.
			{ 'commits'
				. self commits size
				. self commits }.
			{ 'versions'
				. self versions size
				. self versions }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtVersionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Versions';
		priority: 75;
		items: [ self versions ];
		column: 'Index' text: [ :each | each versionNumber ] width: 50;
		column: 'Timestamp' text: [ :each | (ZTimestampFormat fromString: '2001-02-03 16:05') format: each commit timestamp ] width: 110;
		column: 'Commit' text: [ :each | each commit shortId ] width: 100;
		column: 'Author'
			stencil: [ :each | | color |
				color := self colorForAuthor: each commit author.
				BrLabel new
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new foreground: color gtContrastingColor);
					text: each commit author;
					background: color ]
			width: 100;
		column: 'Comment' text: [ :each | each commit comment firstLineWithEllipsis ];
		column: 'Delta' text: [ :each | each commit numberOfLinesChangedDescription ] width: 50;
		column: 'Size' text: [ :each | each lines size ] width: 50
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewAuthorsFor: composite [
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
			text: #numberOfCommits;
		column: 'Lines changed'
			text: [ :each | (self commitsByAuthor: each name) sum: #numberOfLinesChanged ];
		column: 'Lines added'
			text: [ :each | (self commitsByAuthor: each name) sum: #numberOfLinesAdded ];
		column: 'Lines removed'
			text: [ :each | (self commitsByAuthor: each name) sum: #numberOfLinesRemoved ];
		column: 'Lines modified'
			text: [ :each | (self commitsByAuthor: each name) sum: #numberOfLinesModified ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewBlameFor: composite [
	<gtView>
	^ composite forward
		title: 'Blame';
		priority: 50;
		object: [ self file ];
		view: #gtBlameFor:
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewElementFor: composite [
	<gtView>
	^ composite explicit
		title: 'Element';
		priority: 45;
		stencil: [ 
			self asCombinedGraphElement asScrollableElement 
				margin: (BlInsets all: 10) ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewGraphFor: composite [
	<gtView>
	| min max height maxChanged |
	min := SmallInteger maxVal.
	max := maxChanged := 0.
	height := 4.
	^ composite columnedList
		title: 'Graph';
		priority: 40;
		items: [
			self commits do: [ :each | | numberOfLines numberOfLinesChanged |
				numberOfLines := each numberOfLines.
				numberOfLinesChanged := each numberOfLinesChanged abs.
				min := min min: numberOfLines.
				max := max max: numberOfLines.
				maxChanged := maxChanged max: numberOfLinesChanged ].
			self commits ];
		column: 'Change'
			stencil: [ :extendedFileCommit | 
				self horizontalChangeBarElementFor: extendedFileCommit normalized: maxChanged ]
			weight: 1;
		column: 'Ownership' 
			stencil: [ :extendedFileCommit |
				self horizontalOwnershipBarElementFor: extendedFileCommit ]
			weight: 10
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewHistoryFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'History';
		priority: 30;
		items: [ self commits ];
		column: '#' text: [ :_ :index | index ] weight: 0.125;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.333;
		column: 'Commit' text: [ :commit | commit shortId ] weight: 0.25;
		column: 'Author'
			stencil: [ :commit | | color |
				color := (self colorForAuthor: commit author).
				BrLabel new
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new foreground: color gtContrastingColor);
					text: commit author;
					background: color ]
			weight: 0.333;
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ];
		column: 'Delta' text: [ :commit | commit numberOfLinesChangedDescription ] weight: 0.125;
		column: 'Size' text: [ :commit | commit numberOfLines ] weight: 0.125;
		column: 'Top 3 owners' text: [ :commit | commit authorTop3Description ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewKumpelFor: composite [
	<gtView>
	^ composite explicit
		title: 'Kumpel';
		priority: 70;
		tooltip: 'Show line history over time';
		stencil: [ 
			self asKumpelGraphElement beInSeparateCompositionLayer asCanvassableElement
				margin: (BlInsets all: 10) ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewLegendLegendFor: composite [
	<gtView>
	^ composite explicit
		title: 'Legend';
		priority: 51;
		stencil: [ self horizontalAuthorsElement
			margin: (BlInsets all: 10) ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewSuperElementFor: composite [
	<gtView>
	^ composite explicit
		title: 'Super';
		priority: 46;
		stencil: [ 
			self asSuperGraphElement asScrollableElement
				margin: (BlInsets all: 10) ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> horizontalAuthorsElement [
	| container authors |
	container := BrHorizontalFlow new
			hMatchParent;
			vFitContent.
	authors := self authors values sort: #numberOfCommits descending.
	(authors first: (8 min: authors size))
		do: [ :eachAuthor | 
			| label |
			label := BrLabel new
					aptitude: (BrGlamorousLabelAptitude new
							glamorousRegularFont;
							glamorousCodeSmallSize;
							foreground: (self colorForAuthor: eachAuthor name));
					text: ('{1} ({2})'
							format: {eachAuthor name.
									eachAuthor numberOfCommits});
					margin: (BlInsets right: 5).
			label
				when: BlClickEvent
				do: [ :event | event target phlow spawnObject: eachAuthor ].
			container addChild: label ].
	^ container
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> horizontalChangeBarElementFor: extendedFileCommit normalized: maxChanged [
	| element container normalisedNumberOfLinesChanged tooltip |
	(container := BlElement new)
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ].
	normalisedNumberOfLinesChanged := extendedFileCommit numberOfLinesChanged abs / maxChanged.
	tooltip := '{1} {2} {3}' format: { 
		extendedFileCommit numberOfLinesChangedDescription. 
		extendedFileCommit author.
		extendedFileCommit comment }.
	(element := BlElement new)
		background: (self colorForAuthor: extendedFileCommit author);
		addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: self versionThickness.
			c frame horizontal weight: normalisedNumberOfLinesChanged ].
	container addChild: element .
	^ container 
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> horizontalOwnershipBarElementFor: extendedFileCommit [
	| container |
	(container := BlElement new)
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent ].
	extendedFileCommit sortedAuthors doWithIndex: [ :ownership :index |
		| weight tooltip |
		weight := ownership value.
		tooltip := '{1} {2}%' format: { 
			ownership key. 
			ownership value * 100 printShowingDecimalPlaces: 2 }.
		weight > 0 ifTrue: [
			container addChild: (BlElement new
				background: (self colorForAuthor: ownership key);
				addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical exact: self versionThickness.
					c linear weight: weight ]) ] ].
	^ container
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> versionThickness [
	^ PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> verticalChangeBarElementFor: extendedFileCommit normalized: maxChanged [
	| element container normalisedNumberOfLinesChanged tooltip |
	container := BlElement new
			layout: BlFrameLayout new;
			constraintsDo: [ :c | 
				c horizontal fitContent.
				c vertical exact: 30 ].
	normalisedNumberOfLinesChanged := extendedFileCommit numberOfLinesChanged abs
			/ maxChanged.
	tooltip := '{1} {2} {3}'
			format: {extendedFileCommit numberOfLinesChangedDescription.
					extendedFileCommit author.
					extendedFileCommit comment}.
	(element := BlElement new)
		background: (self colorForAuthor: extendedFileCommit author);
		addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
		constraintsDo: [ :c | 
			c horizontal exact: self versionThickness.
			c vertical matchParent.
			c frame vertical weight: normalisedNumberOfLinesChanged.
			c frame vertical alignBottom ].
	container addChild: element.
	^ container
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> verticalCommitLabelElementFor: extendedFileCommit [
	| tooltip element |
	tooltip := ZTimestampFormat verbose format: extendedFileCommit timestamp.
	(element := BrFrame new)
		fitContent;
		constraintsDo: [ :c | 
			c linear vertical alignCenter.
			c linear horizontal alignCenter.
			c vertical exact: 40 ];
		addChild: (BrLabel new
				addAptitude: (BrGlamorousLabelAptitude new
						glamorousCodeTinySize;
						foreground: (self colorForAuthor: extendedFileCommit author));
				addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
				beTinySize;
				text: extendedFileCommit shortId;
				constraintsDo: [ :c | c accountTransformation ];
				transformDo: [ :t | t rotateBy: -90 ]).
	^ element
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> verticalOwnershipBarElementFor: extendedFileCommit [
	| container |
	(container := BlElement new)
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical exact: 30 ].
	extendedFileCommit sortedAuthors reversed doWithIndex: [ :ownership :index |
		| weight tooltip|
		weight := ownership value.
		tooltip := '{1} {2}%' format: { 
			ownership key.
			ownership value * 100 printShowingDecimalPlaces: 2 }.
		weight > 0 ifTrue: [
			container addChild: (BlElement new
				background: (self colorForAuthor: ownership key);
				addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
				constraintsDo: [ :c |
					c horizontal exact: self versionThickness.
					c vertical matchParent.
					c linear weight: weight ]) ] ].
	^ container
]
