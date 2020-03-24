Extension { #name : #IceBranch }

{ #category : #'*GToolkit4Git' }
IceBranch >> gtCommitAncestorsFor: aView [
	<gtView>
	^ (self commit
		gtCommitAncestorsDominanceTreeFor: aView)
			title: 'Commits tree'
]

{ #category : #'*GToolkit4Git' }
IceBranch >> gtCommitsFor: aView [
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
IceBranch >> gtSummaryDescription [
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: self name;
			nextPutAll: ', ';
			nextPutAll: (self isLocal ifTrue: [ 'local' ] ifFalse: [ 'remote' ] ) ]
]
