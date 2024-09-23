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
		column: '# lines removed' text: #numberOfLinesRemoved;
		column: '# lines modified' text: #numberOfLinesModified
]

{ #category : #'*GToolkit4Git' }
UnifiedDiff >> gtViewStatsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Stats';
		priority: 25;
		items: [ {
			{ '# change chunks' . self numberOfChanges }.
			{ '# lines added' . self numberOfLinesAdded }.
			{ '# lines removed' . self numberOfLinesRemoved }.
			{ '# lines added (no modifications)' . self numberOfLinesAdded - self numberOfLinesModified}.
			{ '# lines removed (no modifications)' . self numberOfLinesRemoved - self numberOfLinesModified }.
			{ '# lines modified' . self numberOfLinesModified }.
		} ];
		column: 'key' text: #first weight: 0.5;
		column: 'value' text: #second;
		send: #last
]