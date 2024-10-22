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
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
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
