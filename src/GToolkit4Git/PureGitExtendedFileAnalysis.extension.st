Extension { #name : #PureGitExtendedFileAnalysis }

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileAnalysis >> gtViewGraphFor: composite [
	<gtView>
	| min max scale colors height maxChanged |
	min := self commits min: [ :each | each numberOfLines ].
	max := self commits max: [ :each | each numberOfLines ].
	maxChanged := self commits max: [ :each | each numberOfLinesChanged abs ].
	scale := max reciprocal * 800.
	colors := BrIdentityNormalizer new.
	height := 4.
	^ composite columnedList
		title: 'Graph';
		priority: 40;
		items: [ self commits ];
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
PureGitExtendedFileAnalysis >> gtViewHistoryFor: composite [
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
