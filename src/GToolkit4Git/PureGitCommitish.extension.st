Extension { #name : #PureGitCommitish }

{ #category : #'*GToolkit4Git' }
PureGitCommitish >> gtLogFor: composite [
	<gtView>
	^ (self gtLogViewFor: composite) items: [ self log ]
]

{ #category : #'*GToolkit4Git' }
PureGitCommitish >> gtLogViewFor: composite [
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'Log';
		priority: 30;
		items: [ self log ];
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]
