Extension { #name : #LGitTree }

{ #category : #'*GToolkit4Git' }
LGitTree >> gtViewEntriesFor: aView [
	<gtView>
	^ aView forward
		title: 'Entries List';
		priority: 100;
		object: [ self entries ];
		view: #gtItemsFor:
]

{ #category : #'*GToolkit4Git' }
LGitTree >> gtViewEntriesTreeFor: aView [
	<gtView>
	^ aView tree
		title: 'Entries Tree';
		priority: 102;
		items: [ self entries ];
		children: [ :anEntry | 
			(anEntry object isTree
				ifTrue: [ anEntry tree entries ] 
				ifFalse: [ #() ] )];
		itemText: [ :anEntry | anEntry name ]
]
