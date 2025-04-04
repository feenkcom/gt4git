Extension { #name : #PureGitExtendedFileCommit }

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileCommit >> gtCommitContentsFor: aView [
	<gtView>
	^ aView forward
		title: 'Contents';
		priority: 25;
		object: [ commit ];
		view: #gtContentsFor:
]

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileCommit >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'commit' . self shortId . self commit }.
			{ 'timestamp' . self timestamp }.
			{ 'author' . self author }.
			{ 'comment' . self comment }.
			{ 'number of lines changed' 
				. self numberOfLinesChangedDescription
				. self numberOfLinesChanged }.
			{ 'number of lines added' . self numberOfLinesAdded }.
			{ 'number of lines removed' . self numberOfLinesRemoved }.
			{ 'number of lines modified' . self numberOfLinesModified }.
			{ 'estimated file number of lines' . self numberOfLines ifNil: [ '' ] }.
			{ 'authors top 3' 
				. self authorTop3Description 
				. self authors }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileCommit >> gtViewChangesToParentFor: composite [
	<gtView>
	^ composite forward
		title: 'Changes';
		priority: 30;
		tooltip: 'Changes to parent';
		object: [ self changesToParent ];
		view: #gtViewChangeChunksFor:
]

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileCommit >> gtViewOwnershipFor: composite [
	<gtView>
	| normalizer plotterData |
	self authors isEmpty ifTrue: [ ^ composite empty ].
	^ composite explicit
		title: 'Ownership';
		priority: 40;
		stencil: [
			normalizer := BrExplicitIdentityNormalizer new
					colors: BrGlamorousColors distinctTenLightColors;
					defaultColor: Color veryLightGray.
			plotterData := GtPlotterDataGroup new
					values: (self authors associations sort: #value descending).
			plotterData := plotterData labelled: #key.
			plotterData := plotterData background: [ :each | normalizer value: each key ].
			GtPlotter new horizontalBarChart
				barWidthScale: (GtPlotterLinearScale new domainFrom: 0 to: 1);
				amountOfTicks: 1;
				barWidthData: #value;
				barHeightScale: (GtPlotterConstantScale new constant: 20);
				barLabelSpacing: 150;
				with: plotterData ]
]
