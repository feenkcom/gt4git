Extension { #name : #PureGitExtendedFileCommit }

{ #category : #'*GToolkit4Git' }
PureGitExtendedFileCommit >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'commit' . self shortId . self commit }.
			{ 'number of lines changed' 
				. self numberOfLinesChangedDescription
				. self numberOfLinesChanged }.
			{ 'author' . self author }.
			{ 'number of lines' . self numberOfLines }.
			{ 'authors top 3' 
				. self authorTop3Description 
				. self authors }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
