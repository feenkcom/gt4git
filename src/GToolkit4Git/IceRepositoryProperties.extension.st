Extension { #name : #IceRepositoryProperties }

{ #category : #'*GToolkit4Git' }
IceRepositoryProperties >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'repository' . self repository }.
			{ 'commitish' . self commitish }.
			{ 'file format' . self fileFormat id }.
			{ 'reader class' . self readerClass }.
			{ 'writer class' . self writerClass }.
			{ 'dirty' . self isDirty }.
			{ 'unborn' . self isUnborn }.
		} ];
		column: 'Key' text: #first;
		column: 'Value' text: #second weight: 3;
		send: #last;
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
IceRepositoryProperties >> gtViewPropertiesIn: aView [
	<gtView>
	^ aView forward
		title: 'Properties';
		priority: 30;
		object: [ self properties ];
		view: #gtItemsFor:
]
