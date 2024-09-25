Extension { #name : #PureGitAnnotatedCommit }

{ #category : #'*GToolkit4Git' }
PureGitAnnotatedCommit >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'commit' . self commit shortCommitId . self commit }.
			{ 'parents' . ', ' join: (self parents collect: #shortId) . self parents }.
			{ 'labels' . ', ' join: self labels. self labels }
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
