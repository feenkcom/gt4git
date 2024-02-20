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
		column: 'Event Type' text: [ :anEvent | anEvent eventLabel ] weight: 1;
		column: 'Timestamp' text: #timestamp weight: 1;
		column: 'Duration' text: [ :anEvent | anEvent duration ] weight: 1;
		column: 'Command' text: [ :anEvent | anEvent args first ] weight: 1;
		column: 'Args'
			text: [ :anEvent | 
				String
					streamContents: [ :aStream | 
						anEvent args allButFirst
							do: [ :arg | aStream print: arg ]
							separatedBy: [ aStream nextPut: $  ] ] ] weight: 1;
		yourself
]
