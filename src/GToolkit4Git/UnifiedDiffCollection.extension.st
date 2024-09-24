Extension { #name : #UnifiedDiffCollection }

{ #category : #'*GToolkit4Git' }
UnifiedDiffCollection >> gtViewDiffsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Diffs';
		priority: 30;
		items: [ diffs ];
		column: 'header' text: #header weight: 2;
		column: '# change chunks' text: #numberOfChanges;
		column: '# lines changed' text: #numberOfLinesChanged;
		column: '# lines added' text: #numberOfLinesAdded;
		column: '# lines removed' text: #numberOfLinesRemoved;
		column: '# lines modified' text: #numberOfLinesModified
]
