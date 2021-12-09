Extension { #name : #IceNode }

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewChildrenFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Children';
		priority: 50;
		items: [ self children ];
		column: 'Node' text: [ :aNode | aNode gtDisplayString ];
		column: 'Value' text: [ :aNode | aNode value gtDisplayString ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewDiffFor: aView [
	<gtView>
	((self value isKindOf: IceOperation) or: [
		(self value isKindOf: IceOperationMerge) ])
			ifFalse: [ ^ aView empty ].
	
	^ aView textEditor
		title: 'Diff' translated;
		priority: 20;
		text: [ :anEditor | 
			GtEpiceaDiffStencil new
				from: self value rightContents;
				to: self value leftContents;
				create ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewNodeValuesTreeFor: aView [
	<gtView>
	
	^ aView tree
		title: 'Node values';
		priority: 20;
		items: [ { self } ];
		children: [ :each | each children ];
		itemText: [ :aNode | aNode value gtDisplayString ];
		expandAll;
		send: [ :aNode | aNode value ]
]

{ #category : #'*GToolkit4Git' }
IceNode >> gtViewNodesTreeFor: aView [
	<gtView>
	
	^ aView columnedTree
		title: 'Nodes';
		items: [ { self } ];
		children: [ :each | each children ];
		column: 'Node' text: [ :aNode | aNode gtDisplayString ];
		column: 'Value' text: [ :aNode | aNode value gtDisplayString ];
		expandAll
]
