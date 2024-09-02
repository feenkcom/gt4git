Extension { #name : #PureGitBranch }

{ #category : #'*GToolkit4Git' }
PureGitBranch >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'Name' . self name ifNil: [ '' ] . self name }.
			{ 'Commit' . self commitId . self commit }
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
