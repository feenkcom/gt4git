Extension { #name : #UnifiedDiff }

{ #category : #'*GToolkit4Git' }
UnifiedDiff >> gtViewChangeChunksFor: composite [
	<gtView>
	changeChunks ifNil: [ ^ composite empty ].
	^ composite list
		title: 'Changes';
		priority: 20;
		items: [ changeChunks ];
		itemText: [ :item | item range ]
]
