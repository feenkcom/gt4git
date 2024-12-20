Class {
	#name : #GtGitCliEventsGroup,
	#superclass : #GtBeaconLogEventsGroup,
	#category : #'GToolkit4Git-Libgit-CLI-GT'
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
		column: 'Duration' text: [ :anEvent | anEvent duration ] weight: 0.5;
		column: 'Operation' text: [ :anEvent | anEvent operation ] weight: 0.5;
		column: 'Command' text: [ :anEvent | anEvent firstArg ifNil: [ '' ] ] weight: 0.33;
		column: 'Args'
			text: [ :anEvent | 
				String
					streamContents: [ :aStream | 
						anEvent restArgs
							do: [ :arg | aStream nextPutAll: arg ]
							separatedBy: [ aStream nextPut: $  ] ] ] weight: 2;
		yourself
]
