Extension { #name : #UnifiedDiff }

{ #category : #'*GToolkit4Git' }
UnifiedDiff >> gtViewChangeChunksFor: composite [
	<gtView>
	changeChunks ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'Changes';
		priority: 20;
		items: [ changeChunks ];
		column: 'range' text: #range;
		column: '# lines added' text: #numberOfLinesAdded;
		column: '# lines removed' text: #numberOfLinesRemoved
]
