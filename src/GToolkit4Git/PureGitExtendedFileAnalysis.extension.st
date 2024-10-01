Extension { #name : #PureGitExtendedFileAnalysis }

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileAnalysis >> gtViewGraphFor: composite [
	<gtView>
	| min max scale colors |
	min := self commits min: [ :each | each numberOfLines ].
	max := self commits max: [ :each | each numberOfLines ].
	scale := max reciprocal * 800.
	colors := BrIdentityNormalizer new.
	^ composite list
		title: 'Graph';
		priority: 40;
		items: [ self commits ];
		itemStencil: [
			BlElement new
				layout: BlLinearLayout horizontal;
				constraintsDo: [ :c | 
					c horizontal fitContent.
					c vertical fitContent ] ];
		itemDataBinder: [ :anElement :anItem :anIndex | | width |
			width := 200 + (anItem numberOfLines * scale).
			anElement removeChildren.
			anItem sortedAuthors doWithIndex: [ :ownership :index |
				anElement addChild: (BlElement new
					background: (colors value: ownership key);
					size: ((width * ownership value) rounded @ 10)) ].
			anElement ]
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
