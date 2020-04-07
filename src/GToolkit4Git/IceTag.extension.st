Extension { #name : #IceTag }

{ #category : #'*GToolkit4Git' }
IceTag >> gtCommitAncestorsFor: aView [
	<gtView>
	^ (self commit
		gtCommitAncestorsDominanceTreeFor: aView)
			title: 'Commits tree'
]

{ #category : #'*GToolkit4Git' }
IceTag >> gtCommitsFor: aView [
	<gtView>
	^ aView columnedList 
		title: 'Commits' translated;
		items: [ self commits ];
		column: 'Timestamp' item: [ :aCommit | aCommit timeStamp asStringYMDHM ] width: 120;
		column: 'Commit' item: #shortId width: 70;
		column: 'Author' item: #author;
		column: 'Description' item: #comment
]

{ #category : #'*GToolkit4Git' }
IceTag >> gtHeadCommitDetailsFor: aView [
	<gtView>
	^ self commit gtDetailsFor: aView
]
