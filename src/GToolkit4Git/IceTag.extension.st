Extension { #name : 'IceTag' }

{ #category : '*GToolkit4Git' }
IceTag >> gtCommitAncestorsFor: aView [
	<gtView>
	^ (self commit
		gtCommitAncestorsDominanceTreeFor: aView)
			title: 'Commits tree'
]

{ #category : '*GToolkit4Git' }
IceTag >> gtCommitsFor: aView [
	<gtView>
	^ aView columnedList 
		title: 'Commits' translated;
		items: [ self commits ];
		column: 'Timestamp' text: [ :aCommit | aCommit timeStamp asStringYMDHM ] width: 120;
		column: 'Commit' text: #shortId width: 70;
		column: 'Author' text: #author;
		column: 'Description' text: #comment
]

{ #category : '*GToolkit4Git' }
IceTag >> gtHeadCommitDetailsFor: aView [
	<gtView>
	^ self commit gtDetailsFor: aView
]
