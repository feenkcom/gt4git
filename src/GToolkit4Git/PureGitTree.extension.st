Extension { #name : #PureGitTree }

{ #category : #'*GToolkit4Git' }
PureGitTree >> gtDetails [
	^ super gtDetails , {
		{ 'tree' . self id }.
		{ 'entries'
			. self entries size
			. self entries }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitTree >> gtViewEntriesFor: composite [
	<gtView>
	^ composite columnedTree
		title: 'Entries';
		priority: 40;
		items: [ self entries ];
		children: [ :entry | entry subEntries ];
		column: 'name' text: #name;
		column: 'type' text: #type;
		column: 'mode' text: #mode;
		column: 'id' text: #id;
		contextItemLabel: 'Inspect entry'
			action: [ :element :item | 
				BlTaskAction
					enqueueElement: element
					action: [ element phlow spawnObject: item value ] ];
		send: #resolve
]
