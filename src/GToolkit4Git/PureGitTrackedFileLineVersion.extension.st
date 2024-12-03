Extension { #name : #PureGitTrackedFileLineVersion }

{ #category : #'*GToolkit4Git' }
PureGitTrackedFileLineVersion >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'path' . self path }.
			{ 'extended commit' . self extendedCommit shortId . self extendedCommit }.
			{ 'commit' . self commit shortCommitId . self commit }.
			{ 'line number' . self lineNumber }.
			{ 'line contents' . self lineContents }.
			{ 'tracked file version' . self file }.
			{ 'tracked line' . self line }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
