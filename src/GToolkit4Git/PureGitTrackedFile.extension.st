Extension { #name : #PureGitTrackedFile }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtVersionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Versions';
		items: [ self versions ];
		column: 'Index' text: [ :each | each versionNumber ] width: 50;
		column: 'Timestamp' text: [ :each | (ZTimestampFormat fromString: '2001-02-03 16:05') format: each commit timestamp ] width: 110;
		column: 'Commit' text: [ :each | each commit shortId ] width: 100;
		column: 'Author' text: [ :each | each commit author ] width: 100;
		column: 'Comment' text: [ :each | each commit comment firstLineWithEllipsis ];
		column: 'Delta' text: [ :each | each commit numberOfLinesChangedDescription ] width: 50;
		column: 'Size' text: [ :each | each lines size ] width: 50
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
PureGitTrackedFile >> gtViewGraphFor: composite [
	<gtView>
	| min max colors height maxChanged |
	min := SmallInteger maxVal.
	max := maxChanged := 0.
	colors := BrExplicitIdentityNormalizer new
		colors: BrGlamorousColors distinctTenLightColors;
		defaultColor: Color veryLightGray.
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
			stencil: [ :extendedFileCommit | | element container normalisedNumberOfLinesChanged tooltip |
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
					background: (colors value: extendedFileCommit author);
					addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
					constraintsDo: [ :c |
						c horizontal matchParent.
						c vertical exact: height.
						c frame horizontal weight: normalisedNumberOfLinesChanged ].
				container addChild: element ]
			weight: 1;
		column: 'Ownership' 
			stencil: [ :extendedFileCommit | | container |
				(container := BlElement new)
					layout: BlLinearLayout horizontal;
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ].
				extendedFileCommit sortedAuthors doWithIndex: [ :ownership :index | | weight tooltip |
					weight := ownership value.
					tooltip := '{1} {2}%' format: { ownership key . ownership value * 100 printShowingDecimalPlaces: 2 }.
					weight > 0 ifTrue: [
						container addChild: (BlElement new
							background: (colors value: ownership key);
							addAptitude: (BrGlamorousWithLabelTooltipAptitude text: tooltip);
							constraintsDo: [ :c |
								c horizontal matchParent.
								c vertical exact: height.
								c linear weight: weight ]) ] ].
				container ]
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
		column: 'Author' text: [ :commit | commit author ] weight: 0.333;
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ];
		column: 'Delta' text: [ :commit | commit numberOfLinesChangedDescription ] weight: 0.125;
		column: 'Size' text: [ :commit | commit numberOfLines ] weight: 0.125;
		column: 'Top 3 owners' text: [ :commit | commit authorTop3Description ]
]

{ #category : #'*GToolkit4Git' }
PureGitTrackedFile >> gtViewKumpelFor: composite [
	<gtView>
	| identityIndex |
	^ composite explicit
		title: 'Kumpel';
		priority: 60;
		tooltip: 'Show line history over time';
		stencil: [ | container colors strongColors lightColors |
			lightColors := BrGlamorousColors distinctTenLightColors , { Color veryLightGray }.
			strongColors := BrGlamorousColors distinctTenStrongColors , { Color gray }.
			colors := BrExplicitIdentityNormalizer new
					colors: (1 to: 10);
					defaultColor: 11.
			container := BlElement new.
			self uniqueTrackedLines
				do: [ :trackedLine | 
					| element |
					element := trackedLine asKumpelGraphElement.
					identityIndex := colors value: (self authorOfTrackedLine: trackedLine).
					element
						addAptitude: (BrStyleCommonAptitude new
								default: [ :s | 
									s background: (lightColors at: identityIndex).
									s border: (lightColors at: identityIndex) ];
								hovered: [ :s | 
									s background: (strongColors at: identityIndex) darker.
									s border: (strongColors at: identityIndex) darker ];
								pressed: [ :s | s background: (strongColors at: identityIndex) muchDarker ]).
					element
						when: BlClickEvent
						do: [ :e | e target phlow spawnObject: trackedLine ].
					container addChild: element ].
			container
				size: ((self versions size *  (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
							- PureGitTrackedLine versionMargin)
						@ (PureGitTrackedLine lineHeight * self maxLinesCount).
			container beInSeparateCompositionLayer asCanvassableElement
				margin: (BlInsets all: 10) ]
]
