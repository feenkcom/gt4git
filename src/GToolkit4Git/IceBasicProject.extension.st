Extension { #name : #IceBasicProject }

{ #category : #'*GToolkit4Git' }
IceBasicProject >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'project name' . self projectName }.
			{ 'repository' . self repository }.
			{ 'commitish' . self commitish }.
			{ 'project file path' . self projectFilePath }.
			{ 'source directory' . self sourceDirectory }.
			{ 'tags' . $, join: self tags. self tags }.
			{ 'dirty' . self isDirty }.
		} ];
		column: 'Key' text: #first;
		column: 'Value' text: #second weight: 3;
		send: #last;
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
IceBasicProject >> gtViewPropertiesIn: aView [
	<gtView>
	^ aView forward
		title: 'Properties';
		priority: 30;
		object: [ self properties ];
		view: #gtItemsFor:
]
