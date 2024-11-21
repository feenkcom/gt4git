Extension { #name : #PureGitAuthor }

{ #category : #'*GToolkit4Git' }
PureGitAuthor >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'name' . self name }.
			{ 'color'
				. 9632 asCharacter asRopedText foreground: self color
				. self color }.
			{ 'contrasting color'
				. 9632 asCharacter asRopedText foreground: self contrastColor
				. self contrastColor }.
			{ 'number of commits' . self numberOfCommits}.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
