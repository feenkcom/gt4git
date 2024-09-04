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
		children: [ :entry | 
			entry isTree 
				ifTrue: [ entry resolve entries ] 
				ifFalse: [ #() ] ];
		column: 'name' text: #name;
		column: 'type' text: #type;
		column: 'mode' text: #mode;
		column: 'id' text: #id;
		contextItemLabel: 'Inspect entry' 
			action: [ :element :item |
				element enqueueTask: (BlTaskAction new 
					action: [ element phlow spawnObject: item ]) ];
		send: #resolve
]
