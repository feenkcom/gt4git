Extension { #name : #PureGitCommitish }

{ #category : #'*GToolkit4Git' }
PureGitCommitish >> gtLogFor: composite [
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
