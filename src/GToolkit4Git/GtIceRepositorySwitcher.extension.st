Extension { #name : #GtIceRepositorySwitcher }

{ #category : #'*GToolkit4Git' }
GtIceRepositorySwitcher >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'repository' . self iceRepository }.
			{ 'ssh url' . self sshUrl }.
			{ 'directory' . self directory }.
			{ 'iceberg home' . self icebergLocation }.
			{ 'creator' . self creator }.
		} ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
