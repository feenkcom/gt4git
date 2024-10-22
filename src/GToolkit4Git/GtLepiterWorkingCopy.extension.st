Extension { #name : #GtLepiterWorkingCopy }

{ #category : #'*GToolkit4Git' }
GtLepiterWorkingCopy >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			{ 'repository' . self repository }.
			{ 'databases' . self databases }.
			{ 'changes strategy' . self lepiterChangesStragegy }.
		} ];
		column: 'Key' text: #first;
		column: 'Value' text: #second weight: 3;
		send: #last;
		actionUpdateButton
]
