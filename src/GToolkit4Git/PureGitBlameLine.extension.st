Extension { #name : #PureGitBlameLine }

{ #category : #'*GToolkit4Git' }
PureGitBlameLine >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'path' . self path }.
			{ 'line number' . self lineNumber }.
			{ 'line' . self line }.
			{ 'author' . self author }.
			{ 'timestmap' . self timestamp }.
			{ 'commit' . self commit shortCommitId . self commit }.
			{ 'comment' . self commit comment }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitBlameLine >> gtHistoryFor: composite [
	<gtView>
	| timestampFormat colors |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	colors := BrExplicitIdentityNormalizer new
		colors: BrGlamorousColors distinctTenLightColors;
		defaultColor: Color veryLightGray.
	^ composite columnedList
		title: 'History';
		priority: 50;
		tooltip: 'Show history of changes for this line';
		items: [ self history ];
		column: 'Timestamp' 
			text: [ :blameLine | timestampFormat format: blameLine timestamp ] 
			weight: 0.33;
		column: 'Commit' 
			text: [ :blameLine | blameLine shortId ] 
			weight: 0.165;
		column: 'Author' 
			stencil: [ :blameLine | | color |
				color := colors value: blameLine author.
				BrLabel new
					layout: BlLinearLayout horizontal;
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					aptitude: (BrGlamorousLabelAptitude new 
									foreground: color gtContrastingColor) ;
					text: blameLine author;
					background: color ]
			weight: 0.5;
		column: 'Line' 
			stencil: [ :blameLine |
				BrLabel new
					aptitude: BrGlamorousLabelAptitude new editorMeasurement;
					text: blameLine line ]
			weight: 2.0
]

{ #category : #'*GToolkit4Git' }
PureGitBlameLine >> gtViewLineIn: composite [
	<gtView>
	^ composite textEditor
		title: 'Line';
		priority: 30;
		text: [ self line ];
		glamorousCodeFontAndSize
]
