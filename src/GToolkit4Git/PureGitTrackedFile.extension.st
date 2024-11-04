Extension { #name : #PureGitTrackedFile }

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
	| min max scale colors height maxChanged |
	min := SmallInteger maxVal.
	max := maxChanged := scale := 0.
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
			scale := max reciprocal * 800.
			self commits ];
		column: 'Commit'
			stencil: [ :item | | width |
				width := (item numberOfLinesChanged abs / maxChanged * 50) max: 10.
				BlElement new
					background: (colors value: item author);
					size: width @ height ]
			width: 60;
		column: 'Ownership' 
			stencil: [ :item | | element width |
				element := BlElement new
					layout: BlLinearLayout horizontal;
					constraintsDo: [ :c | 
						c horizontal fitContent.
						c vertical fitContent ].
				width := 200 + (item numberOfLines * scale).
				item sortedAuthors doWithIndex: [ :ownership :index |
					element addChild: (BlElement new
						background: (colors value: ownership key);
						size: ((width * ownership value) rounded @ height)) ].
				element ]
			width: 1000
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
		stencil: [ | container colors strongColors lightColors |
			lightColors := BrGlamorousColors distinctTenLightColors
					, {Color veryLightGray}.
			strongColors := BrGlamorousColors distinctTenStrongColors , {Color gray}.
			colors := BrExplicitIdentityNormalizer new
					candidates: (1 to: 10);
					defaultCandidate: 11.
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
				size: ((self versions size *  (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin)) - PureGitTrackedLine versionMargin)
						@ (PureGitTrackedLine lineHeight * self maxLinesCount).
			container beInSeparateCompositionLayer asScrollableElement
				margin: (BlInsets all: 10) ];
		tooltip: 'Show line history over time'
]
