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

{ #category : #'*GToolkit4Git' }
UnifiedDiffCollection >> gtViewDiffsTreeFor: composite [
	<gtView>
	^ composite columnedTree
		title: 'Tree';
		priority: 20;
		items: [ Array with: self ];
		children: #children;
		column: 'Description' text: #description;
		expandAll
]

{ #category : #'*GToolkit4Git' }
UnifiedDiffCollection >> gtViewStatsFor: composite [
	<gtView>
	self diffs ifNil: [ ^ composite empty ].
	^ composite columnedList
		title: 'Stats';
		priority: 40;
		items: [ {
			{ 'description' . self description }.
			{ '# changed files' . self numberOfChanges }.
			{ '# lines added' . self numberOfLinesAdded }.
			{ '# lines removed' . self numberOfLinesRemoved }.
		} ];
		column: 'key' text: #first weight: 0.5;
		column: 'value' text: #second;
		send: #last
]
