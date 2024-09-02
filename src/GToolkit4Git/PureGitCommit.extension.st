Extension { #name : #PureGitCommit }

{ #category : #'*GToolkit4Git' }
PureGitCommit >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'Commit' . self id  }.
			{ 'Parents'
				. self parentIds asCommaString
				. self parentIds collect: [ :each | self repository resolveCommit: each ] }.
			{ 'Author' . self author }.
			{ 'Timestamp' . self timestamp }.
			{ 'Comment' . self comment }
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
