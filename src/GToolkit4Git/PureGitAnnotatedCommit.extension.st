Extension { #name : #PureGitAnnotatedCommit }

{ #category : #'*GToolkit4Git' }
PureGitAnnotatedCommit >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'Commit' . self commit id . self commit }.
			{ 'Parents' . ', ' join: (self parents collect: #id) . self parents }.
			{ 'Labels' . ', ' join: self labels. self labels }
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
