Extension { #name : #PureGitRepositoryObject }

{ #category : #'*GToolkit4Git' }
PureGitRepositoryObject >> gtDetails [
	^ {
		{ 'repository' . self repository }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitRepositoryObject >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ self gtDetails ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		actionUpdateButton;
		updateWhen: PureGitRepositoryModified in: [ self repository announcer ];
		send: #last
]
