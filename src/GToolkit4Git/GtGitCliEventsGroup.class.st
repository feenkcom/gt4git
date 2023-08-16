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
		column: 'Event Type' text: [ :anEvent | anEvent class eventLabel ];
		column: 'Timestamp' text: #timestamp;
		column: 'Duration' text: [ :anEvent | anEvent duration ];
		column: 'Command' text: [ :anEvent | anEvent args first ];
		column: 'Args'
			text: [ :anEvent | 
				String
					streamContents: [ :aStream | 
						anEvent args allButFirst
							do: [ :arg | aStream print: arg ]
							separatedBy: [ aStream nextPut: $  ] ] ];
		yourself
]
