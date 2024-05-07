Class {
	#name : #GtGitCliEventsGroup,
	#superclass : #GtBeaconLogEventsGroup,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCliEventsGroup >> gtItemsFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Events';
		priority: 10;
		items: [ self ];
		children: #subEvents;
		column: 'Event Type' text: [ :anEvent | anEvent eventLabel ] weight: 0.5;
		column: 'Timestamp' text: #timestamp weight: 0.5;
		column: 'Duration' text: [ :anEvent | anEvent duration ] weight: 0.33;
		column: 'Command' text: [ :anEvent | anEvent args first ] weight: 0.33;
		column: 'Args'
			text: [ :anEvent | 
				String
					streamContents: [ :aStream | 
						anEvent args allButFirst
							do: [ :arg | aStream nextPutAll: arg ]
							separatedBy: [ aStream nextPut: $  ] ] ] weight: 2;
		yourself
]
